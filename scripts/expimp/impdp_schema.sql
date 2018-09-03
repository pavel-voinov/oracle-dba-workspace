set serveroutput on size 1000000 buffer 1000000 verify off timing on scan on autotrace off

define p_schema=&1
define p_dir=&2
define p_dumpfile=&3

declare
  l_handle     number;
  l_schema     varchar2(30) := upper('&p_schema');
  l_dir        varchar2(30) := upper('&p_dir');
  l_dump       varchar2(255) := '&p_dumpfile';
  l_job        varchar2(255);

  cursor default_ts is
    SELECT default_tablespace, temporary_tablespace
    FROM dba_users
    WHERE username = l_schema;

  l_ts varchar(30);
  l_tmp_ts varchar(30);

  function exists_ts(
    p_Name varchar2)
    return boolean
  as
    l_num integer;
  begin
    SELECT count(*) INTO l_num
    FROM dba_tablespaces
    WHERE tablespace_name = p_Name;

    return l_num = 1;
  end exists_ts;

begin
  l_job := 'IMP_' || l_schema || '_' || to_char(systimestamp, 'YYYYMMDD');

  open default_ts;
  fetch default_ts into l_ts, l_tmp_ts;
  close default_ts;

  l_ts := nvl(l_ts, l_schema || '_DATA');
  l_tmp_ts := nvl(l_tmp_ts, 'TEMP');

  l_handle := dbms_datapump.open (operation => 'IMPORT', job_mode => 'SCHEMA', job_name => l_job, version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => l_handle, degree => 4);
  dbms_datapump.add_file(handle => l_handle, filename => l_job || '.log', directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(''' || l_schema || ''')');

--  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'TEMP', value => 'TEMP');
--  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => '%', value => l_ts);

  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.set_parameter(handle => l_handle, name => 'TABLE_EXISTS_ACTION', value => 'SKIP');
  dbms_datapump.set_parameter(handle => l_handle, name => 'SKIP_UNUSABLE_INDEXES', value => 0);
  dbms_datapump.metadata_transform(handle => l_handle, name => 'OID', value => 0);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'',''DB_LINK'',''JOB'',''GRANT'',''REFRESH_GROUP'',''MATERIALIZED_VIEW_LOG'',''DOMAIN_INDEX'')');
--  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'',''DB_LINK'',''JOB'',''GRANT'',''REFRESH_GROUP'',''MATERIALIZED_VIEW'',''MATERIALIZED_VIEW_LOG'',''DOMAIN_INDEX'')');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');

  dbms_datapump.log_entry(handle => l_handle, message => 'Import started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);

  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0, cluster_ok => 0);
  dbms_datapump.detach(handle => l_handle);
end;
/
