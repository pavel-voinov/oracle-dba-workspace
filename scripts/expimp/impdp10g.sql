set serveroutput on size 1000000 buffer 1000000 verify off timing on scan on autotrace off

declare
  l_handle     number;
  l_old_schema varchar2(30) := upper('&1');
  l_schema     varchar2(30) := upper('&2');
  l_dir        varchar2(30) := upper('&3');
  l_dump       varchar2(255) := '&4';
  l_job        varchar2(255);

  l_data_ts varchar(30);
  l_users_ts varchar(30);
  l_gls_ts varchar(30);
  l_temp_ts varchar(30);

  cursor default_ts is
    SELECT default_tablespace, temporary_tablespace
    FROM dba_users
    WHERE username = upper(l_schema);

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
    WHERE tablespace_name = upper(p_Name);

    return l_num = 1;
  end exists_ts;

begin
  l_job := 'IMPORT_' || l_schema || '_' || to_char(systimestamp, 'YYYYMMDD');

  open default_ts;
  fetch default_ts into l_ts, l_tmp_ts;
  close default_ts;

  l_data_ts := nvl(l_ts, 'USERS');
  l_users_ts := nvl(l_ts, 'USERS');
  l_gls_ts := nvl(l_ts, 'USERS');
  l_temp_ts := nvl(l_tmp_ts, 'TEMP');

  l_handle := dbms_datapump.open (operation => 'IMPORT', job_mode => 'SCHEMA', job_name => l_job, version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => l_handle, degree => 1);
  dbms_datapump.add_file(handle => l_handle, filename => l_job || '.log', directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(''' || l_old_schema || ''')');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_SCHEMA', old_value => l_old_schema, value => l_schema);
  if exists_ts(l_schema || '_DATA') then
    l_data_ts := l_schema || '_DATA';
  end if;
  if exists_ts(l_schema || '_USERS') then
    l_users_ts := l_schema || '_USERS';
  end if;
  if exists_ts(l_schema || '_GLS') then
    l_gls_ts := l_schema || '_GLS';
  end if;
  if exists_ts(l_schema || '_TEMP') then
    l_temp_ts := l_schema || '_TEMP';
  end if;
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema, value => l_data_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_TS', value => l_data_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_DATA', value => l_data_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_INDEX', value => l_data_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_GLS', value => l_gls_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_USERS', value => l_users_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'NEXT_GEN_ASM1', value => l_data_ts);
  if l_users_ts <> 'USERS' then
    dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'USERS', value => l_users_ts);
  end if;
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_TEMP', value => l_temp_ts);
  if l_temp_ts <> 'TEMP' then
    dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'TEMP', value => l_temp_ts);
  end if;
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => '%', value => l_data_ts);
  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.set_parameter(handle => l_handle, name => 'TABLE_EXISTS_ACTION', value => 'TRUNCATE');
  dbms_datapump.set_parameter(handle => l_handle, name => 'SKIP_UNUSABLE_INDEXES', value => 0);
  dbms_datapump.metadata_transform(handle => l_handle, name => 'OID', value => 0);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'')');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');

  dbms_datapump.log_entry(handle => l_handle, message => 'Import started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);
  dbms_datapump.log_entry(handle => l_handle, message => 'Job handle: ' || l_handle, log_file_only => 1);

  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0);
  dbms_datapump.detach(handle => l_handle);
end;
/
