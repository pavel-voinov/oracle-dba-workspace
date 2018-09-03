/*
*/
set serveroutput on size unlimited buffer 100000 verify off timing off scan on

ACCEPT p_dir DEFAULT 'DATAPUMP_DIR' PROMPT "Enter Oracle directory name with dump files. [DATAPUMP_DIR]: "
ACCEPT p_dump PROMPT "Enter dumpfile name(s).: "
ACCEPT p_schema PROMPT "Enter schema(s) to import, delimited by comma [empty for all]: "
ACCEPT p_tgt_schema DEFAULT '&p_schema' PROMPT "Enter names of target schema(s) to import, delimited by comma [&p_schema]: "

set term off

variable v_job varchar2(255)
variable v_log varchar2(255)

column p_schema new_value p_schema
column p_tgt_schema new_value p_tgt_schema
column p_dir new_value p_dir
column p_dir_path new_value p_dir_path
column p_run_as_job new_value p_run_as_job
column p_tables new_value p_tables
column p_dump new_value p_dump
column p_log new_value p_log
column p_job_default new_value p_job_default
column p_job new_value p_job
column p_continue new_value p_continue
column p_parallel new_value p_parallel
column p_content new_value p_content

SELECT upper(replace(trim('&p_schema'), ' ')) as p_schema, upper(replace(trim('&p_tgt_schema'), ' ')) as p_tgt_schema,
  nvl(upper('&p_dir'), 'DATAPUMP_DIR') as p_dir
FROM dual
/

declare
  l_schema varchar2(1024) := '&p_schema';
  l_job    varchar2(255);
  i        integer;
  l_ts     varchar2(8);
  l_tmp    varchar2(255);
begin
  i := instr(l_schema, ',');
  l_ts := to_char(systimestamp, 'YYYYMMDD');
  l_tmp := replace(upper(sys_context('USERENV', 'DB_DOMAIN')), 'INT.THOMSONREUTERS.COM');
  if l_tmp is null then
    l_tmp := sys_context('USERENV', 'DB_NAME');
  else
    l_tmp := sys_context('USERENV', 'DB_NAME') || '_' || l_tmp;
  end if;  
  if i > 0 then
    l_job := 'IMP_' || regexp_replace(l_schema, ',.*$') || '_' || l_ts;
  else
    l_job := 'IMP_' || l_schema || '_' || l_ts;
  end if;
  SELECT l_job, l_job || '.log' INTO :v_job, :v_log FROM dual;
end;
/
SELECT :v_job as p_job_default, :v_log as p_log FROM dual
/
set term on

ACCEPT p_log DEFAULT '&p_log' PROMPT "Enter logfile name. [&p_log]: "
ACCEPT p_job DEFAULT '&p_job_default' PROMPT "Enter name for export job. [&p_job_default]: "
ACCEPT p_parallel DEFAULT 1 PROMPT "Use parallel degree. [1]: "
ACCEPT p_tables PROMPT "Enter list of tables to export. [If not specified all tables will be exported]: "
ACCEPT p_content DEFAULT 'ALL' PROMPT "Content type to export (ALL, METADATA_ONLY, DATA_ONLY). [ALL]: "
ACCEPT p_run_as_job DEFAULT 'Y' PROMPT "Do you need to run export as job (Y/N)?. [Y]: "

set term off

SELECT nvl(upper(substr('&p_run_as_job', 1, 1)), 'Y') as p_run_as_job,
  trim(replace(upper('&p_tables'), ' ')) as p_tables
FROM dual
/
SELECT directory_path as p_dir_path FROM dba_directories WHERE directory_name = '&p_dir'
/
set term on

set feedback on heading on

PROMPT
PROMPT ===============================================
PROMPT You have selected:
PROMPT ===============================================
PROMPT    Directory: &p_dir (&p_dir_path)
PROMPT  Dumpfile(s): &p_dump
PROMPT Source schema(s): &p_schema
PROMPT Target schema(s): &p_tgt_schema
PROMPT     Log file: &p_log
PROMPT     Job name: &p_job
PROMPT     Parallel: &p_parallel
PROMPT       Tables: &p_tables
PROMPT Content type: &p_content
PROMPT   Run as job: &p_run_as_job
PROMPT

ACCEPT p_continue DEFAULT 'Y' PROMPT "Run export with parameters above (Y/N). [Y]: "

set term off
SELECT nvl(upper(substr('&p_continue', 1, 1)), 'Y') as p_continue FROM dual
/
set term on

set feedback off heading off

begin
  if '&p_continue' <> 'Y' then
    raise_application_error(-20000, 'Operation has cancelled');
  end if;
end;
/

PROMPT
PROMPT Import job name is "&p_job"
PROMPT Please look at logfile "&p_dir_path./&p_log" for the progress
PROMPT
@expimp/p/impdp.sql

undefine p_schema
undefine p_dir
undefine p_dir_path
undefine p_run_as_job
undefine p_tables
undefine p_dump_mask
undefine p_dump
undefine p_log
undefine p_job_default
undefine p_job
undefine p_continue
undefine p_content
