/*
*/
set serveroutput on size unlimited buffer 100000 verify off timing off scan on

ACCEPT p_tablespace PROMPT "Enter tablespace name to export: "
ACCEPT p_dir DEFAULT DATAPUMP_DIR PROMPT "Enter Oracle directory name to place dump files. [DATAPUMP_DIR]: "

set termout off

variable v_dump varchar2(255)
variable v_job  varchar2(255)

column p_dir new_value p_dir
column p_dir_path new_value p_dir_path
column p_dump_mask new_value p_dump_mask
column p_dump new_value p_dump
column p_tablespace new_value p_tablespace
column p_log new_value p_log
column p_job_default new_value p_job_default
column p_job new_value p_job
column p_continue new_value p_continue
column p_reusefile new_value p_reusefile
column p_cluster_ok new_value p_cluster_ok
column p_version new_value p_version

SELECT nvl(upper('&p_dir'), 'DATAPUMP_DIR') as p_dir, upper('&p_tablespace') as p_tablespace FROM dual
/
declare
  l_dump   varchar2(255);
  l_job    varchar2(255);
  i        integer;
  l_ts     varchar2(8);
begin
  l_ts := to_char(systimestamp, 'YYYYMMDD');
  l_dump := upper(sys_context('USERENV', 'DB_NAME')) || '_TABLESPACE_' || l_ts;
  l_job := 'EXP_TABLESPACE_' || l_ts;
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

ACCEPT p_dump PROMPT "Enter dumpfile(s) name(s). [&p_dump_mask._%U.dmp]: "
ACCEPT p_log PROMPT "Enter logfile name. [&p_dump_mask..log]: "
ACCEPT p_job PROMPT "Enter name for export job. [&p_job_default]: "

set term off

SELECT nvl('&p_dump.', '&p_dump_mask._%U.dmp') as p_dump,
  nvl('&p_log.', '&p_dump_mask..log') as p_log,
  nvl('&p_job.', '&p_job_default') as p_job
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
PROMPT   Tablespace: &p_tablespace
PROMPT    Directory: &p_dir (&p_dir_path)
PROMPT  Dumpfile(s): &p_dump
PROMPT     Log file: &p_log
PROMPT     Job name: &p_job

ACCEPT p_continue DEFAULT Y PROMPT "Run export with parameters above (Y/N). [Y]: "

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

declare
  l_handle integer;
  l_dir    varchar2(30) := '&p_dir';
  l_dump   varchar2(255) := '&p_dump';
  l_log    varchar2(255) := '&p_log';
  l_job    varchar2(255) := '&p_job';
  l_tablespace varchar2(30) := upper('&p_tablespace');
begin
  l_handle := dbms_datapump.open (operation => 'EXPORT', job_mode => 'TRANSPORTABLE', job_name => l_job, version => 'COMPATIBLE');

  dbms_datapump.set_parallel(handle => l_handle, degree => 1);

  dbms_datapump.add_file(handle => l_handle, filename => l_log, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE &p_reusefile);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE, filesize => '4G' &p_reusefile);

  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.set_parameter(handle => l_handle, name => 'TTS_FULL_CHECK', value => 1);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'TABLESPACE_EXPR', value => 'IN(''' || l_tablespace || ''')');
  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);

  dbms_datapump.log_entry(handle => l_handle, message => 'Export started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);

  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0 &p_cluster_ok);
  dbms_datapump.detach(handle => l_handle); 
exception when others then
  dbms_output.enable(null);
  dbms_output.put_line(SQLERRM);
  begin
    dbms_datapump.stop_job(handle => l_handle, immediate => 1, keep_master => 0);
  exception when others then
    null;
  end;
end;
/

set feedback on heading on

PROMPT
PROMPT Export job "&p_job" has started
PROMPT Please look at log "&p_dir_path./&p_log" for progress
PROMPT

undefine p_dir
undefine p_dir_path
undefine p_dump_mask
undefine p_dump
undefine p_log
undefine p_job_default
undefine p_job
undefine p_continue
undefine p_reusefile
undefine p_cluster_ok
undefine p_version
