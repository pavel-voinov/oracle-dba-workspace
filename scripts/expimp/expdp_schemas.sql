/*

This is simplified version of expdp.sql and p/expdp.sql scripts
*/
set serveroutput on size 1000000 buffer 100000 verify off timing off scan on

define p_schema=&1
define p_dir=&2
define p_dump_mask=&3

set termout off
column p_dump new_value p_dump
column p_log new_value p_log
column p_job new_value p_job
SELECT '&p_dump_mask._%U.dmp' as p_dump, '&p_dump_mask..log' as p_log, 'EXP_&p_dump_mask.' as p_job
FROM dual;
set termout on

define p_parallel=2
define p_tables=''
define p_content=ALL
define p_run_as_job=Y

declare
  l_handle integer;
  l_schema varchar2(1024) := '&p_schema';
  l_dir    varchar2(30) := '&p_dir';
  l_dump   varchar2(255) := '&p_dump';
  l_log    varchar2(255) := '&p_log';
  l_job    varchar2(255) := '&p_job';
  l_tables varchar2(32000) := '&p_tables';
  l_mode   varchar2(10) := 'SCHEMA';
  l_state  varchar2(255);
  l_scn    number;
begin
  dbms_output.enable(null);

  l_schema := regexp_replace(replace(trim(l_schema), ' '), '(^|,)?([^,]+)(,|$)?', '\1''\2''\3');
  if l_tables is not null then
    l_mode := 'TABLE';
    l_tables := regexp_replace(replace(trim(l_tables), ' '), '(^|,)?([^,]+)(,|$)?', '\1''\2''\3');
  end if;

  l_handle := dbms_datapump.open (operation => 'EXPORT', job_mode => l_mode, job_name => l_job, version => 'COMPATIBLE');

  if instr(l_dump, '%U') = 0 then
    dbms_datapump.set_parallel(handle => l_handle, degree => 1);
    dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE, reusefile => 1);
  else
    dbms_datapump.set_parallel(handle => l_handle, degree => &p_parallel);
    dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE, filesize => '8G', reusefile => 1);
  end if;
  dbms_datapump.add_file(handle => l_handle, filename => l_log, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE, reusefile => 1);

  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  if '&p_content' in ('ALL', 'METADATA_ONLY') then
    dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  else
    dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 0);
  end if;
  SELECT min(current_scn) INTO l_scn FROM gv$database;
  dbms_datapump.set_parameter(handle => l_handle, name => 'FLASHBACK_SCN', value => l_scn);

  if '&p_content' in ('ALL', 'DATA_ONLY') then
    dbms_datapump.data_filter(handle => l_handle, name => 'INCLUDE_ROWS', value => 1);
  else
    dbms_datapump.data_filter(handle => l_handle, name => 'INCLUDE_ROWS', value => 0);
  end if;
  dbms_datapump.set_parameter(handle => l_handle, name => 'COMPRESSION', value => 'ALL');

  if l_mode = 'TABLE' then
    dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'IN(' || l_tables || ')', object_type => 'TABLE');
  end if;

  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(' || l_schema || ')');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'')');
  -- ignore special db objects for JChem indexed tables
  if l_mode = 'SCHEMA' then
    dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');
  end if;

  dbms_datapump.log_entry(handle => l_handle, message => 'Export started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);
  dbms_datapump.log_entry(handle => l_handle, message => 'SCN: ' || l_scn, log_file_only => 1);

  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0, cluster_ok => 0);
  if '&p_run_as_job' = 'Y' then
    dbms_datapump.detach(handle => l_handle);
  else
    dbms_datapump.wait_for_job(handle => l_handle, job_state => l_state);
  end if;
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
