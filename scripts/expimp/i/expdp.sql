/*
*/
set serveroutput on size unlimited buffer 100000 verify off timing off scan on feedback off

ACCEPT p_schema PROMPT "Enter schema(s) to export, delimited by comma: "
ACCEPT p_dir DEFAULT 'DATAPUMP_DIR' PROMPT "Enter Oracle directory name to place dump files. [DATAPUMP_DIR]: "

set term on
declare
  l_cnt number;
begin
  SELECT count(*) into l_cnt
  FROM dba_directories
  WHERE directory_name = '&p_dir';

  if l_cnt = 0 then
    raise_application_error(-20000, 'Oracle directory &p_dir is not found');
  end if;
end;
/

variable v_dump varchar2(255)
variable v_job  varchar2(255)
variable v_scn  number

column p_schema new_value p_schema
column p_dir new_value p_dir
column p_dir_path new_value p_dir_path
column p_use_scn new_value p_use_scn
column p_run_as_job new_value p_run_as_job
column p_tables new_value p_tables
column p_dump_mask new_value p_dump_mask
column p_dump new_value p_dump
column p_log new_value p_log
column p_job_default new_value p_job_default
column p_job new_value p_job
column p_scn new_value p_scn
column p_scn_desc new_value p_scn_desc
column p_continue new_value p_continue
column p_parallel new_value p_parallel
column p_content new_value p_content
column p_reusefile new_value p_reusefile
column p_cluster_ok new_value p_cluster_ok
column p_version new_value p_version

set termout off
SELECT upper(replace(trim('&p_schema'), ' ')) as p_schema, nvl(upper('&p_dir'), 'DATAPUMP_DIR') as p_dir FROM dual
/
declare
  l_schema varchar2(1024) := '&p_schema';
  l_dump   varchar2(255);
  l_job    varchar2(255);
  i        integer;
  l_ts     varchar2(8);
  l_tmp    varchar2(255);
begin
  i := instr(l_schema, ',');
  l_ts := to_char(systimestamp, 'YYYYMMDD');
  l_tmp := replace(replace(upper(sys_context('USERENV', 'DB_DOMAIN')), 'INT.THOMSONREUTERS.COM'), 'CORTELLIS.INT.CLARIVATE.COM');
  if l_tmp is null then
    l_tmp := sys_context('USERENV', 'DB_NAME');
  else
    l_tmp := sys_context('USERENV', 'DB_NAME') || '_' || l_tmp;
  end if; 
  if i > 0 then
    l_dump := upper(l_tmp) || '_' || substr(l_schema, 1, i - 1) || '_' || l_ts;
    l_job := 'EXP_' || substr(l_schema, 1, i - 1) || '_' || l_ts;
  else
    l_dump := upper(l_tmp) || '_' || l_schema || '_' || l_ts;
    l_job := 'EXP_' || l_schema || '_' || l_ts;
  end if;
  SELECT l_dump, l_job INTO :v_dump, :v_job FROM dual;
end;
/
SELECT :v_dump as p_dump_mask, :v_job as p_job_default FROM dual
/
SELECT decode(version, 10, '', ', cluster_ok => 0') as p_cluster_ok,
  decode(version, 10, '', ', reusefile => 1') as p_reusefile,
  version as p_version
FROM (SELECT to_number(substr(version, 1, instr(version, '.') - 1)) as version FROM v$instance)
/
set term on

ACCEPT p_dump DEFAULT '&p_dump_mask._%U.dmp' PROMPT "Enter dumpfile(s) name(s). [&p_dump_mask._%U.dmp]: "
set term off
SELECT regexp_replace('&p_dump', '((_|-|)(|%U))(|\.dmp)$', '', 1, 1, 'i') as p_dump_mask FROM dual;
set term on

ACCEPT p_log PROMPT "Enter logfile name. [&p_dump_mask..log]: "
ACCEPT p_job PROMPT "Enter name for export job. [&p_job_default]: "
ACCEPT p_use_scn DEFAULT 'Y' PROMPT "Do you need consistent dump by current SCN (Y/N)?. [Y]: "
ACCEPT p_parallel DEFAULT 1 PROMPT "Use parallel degree. [1]: "
ACCEPT p_tables PROMPT "Enter list of tables to export. [If not specified all tables will be exported]: "
ACCEPT p_content DEFAULT 'ALL' PROMPT "Content type to export (ALL, METADATA_ONLY, DATA_ONLY). [ALL]: "
ACCEPT p_run_as_job DEFAULT 'Y' PROMPT "Do you need to run export as job (Y/N)?. [Y]: "

set term off

SELECT nvl(upper(substr('&p_use_scn', 1, 1)), 'Y') as p_use_scn,
  nvl(upper(substr('&p_run_as_job', 1, 1)), 'Y') as p_run_as_job,
  nvl(upper(trim('&p_content')), 'ALL') as p_content,
  trim(replace(upper('&p_tables'), ' ')) as p_tables,
  nvl('&p_dump.', '&p_dump_mask._%U.dmp') as p_dump,
  nvl('&p_log.', '&p_dump_mask..log') as p_log,
  nvl('&p_job.', '&p_job_default') as p_job,
  nvl('&p_parallel.', '1') as p_parallel
FROM dual
/
begin
  SELECT decode('&p_use_scn', 'Y', min(current_scn), null) INTO :v_scn FROM gv$database;
end;
/
SELECT trim(to_char(:v_scn, '999999999999990')) as p_scn FROM dual
/
SELECT decode('&p_use_scn', 'Y', 'Y (SCN=&p_scn)', 'N') as p_scn_desc FROM dual
/
SELECT directory_path as p_dir_path FROM dba_directories WHERE directory_name = '&p_dir'
/
set term on

PROMPT
PROMPT ===============================================
PROMPT You have selected:
PROMPT ===============================================
PROMPT    Schema(s): &p_schema
PROMPT    Directory: &p_dir (&p_dir_path)
PROMPT  Dumpfile(s): &p_dump
PROMPT     Log file: &p_log
PROMPT     Job name: &p_job
PROMPT      Use SCN: &p_scn_desc
PROMPT     Parallel: &p_parallel
PROMPT       Tables: &p_tables
PROMPT Content type: &p_content
PROMPT   Run as job: &p_run_as_job
PROMPT

ACCEPT p_continue DEFAULT 'Y' PROMPT "Run export with parameters above (Y/N). [Y]: "

set term off
column p_script_name new_value p_script_name
SELECT decode(nvl(upper(substr('&p_continue', 1, 1)), 'Y'), 'Y', 'expimp/p/expdp.sql', 'cancel.sql') as p_script_name FROM dual;
set term on

set feedback off heading off

@&p_script_name

undefine p_schema
undefine p_dir
undefine p_dir_path
undefine p_use_scn
undefine p_run_as_job
undefine p_tables
undefine p_dump_mask
undefine p_dump
undefine p_log
undefine p_job_default
undefine p_job
undefine p_continue
undefine p_content
undefine p_reusefile
undefine p_cluster_ok
undefine p_version
undefine p_script_name
