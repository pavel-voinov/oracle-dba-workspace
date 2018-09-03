set serveroutput on size 1000000 buffer 1000000 verify off timing on scan on autotrace off

declare
  h1   NUMBER;
  l_old_schema varchar2(30) := upper('&1');
  l_schema varchar2(30) := upper('&2');
  l_dump varchar2(255) := '&3';

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
  open default_ts;
  fetch default_ts into l_ts, l_tmp_ts;
  close default_ts;

  l_data_ts := nvl(l_ts, 'USERS');
  l_users_ts := nvl(l_ts, 'USERS');
  l_gls_ts := nvl(l_ts, 'USERS');
  l_temp_ts := nvl(l_tmp_ts, 'TEMP');

  h1 := dbms_datapump.open (operation => 'SQL_FILE', job_mode => 'SCHEMA', job_name => 'IMPORT_' || l_schema, version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => h1, degree => 1);
  dbms_datapump.add_file(handle => h1, filename => 'IMPORT_' || l_schema || '.log', directory => 'EXP_SCHEMES_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => h1, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => h1, filename => l_dump || '_%U.dmp', directory => 'EXP_SCHEMES_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
  dbms_datapump.add_file(handle => h1, filename => 'IMPORT_' || l_schema || '.sql', directory => 'EXP_SCHEMES_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_SQL_FILE);
  dbms_datapump.metadata_filter(handle => h1, name => 'SCHEMA_EXPR', value => 'IN(''' || l_old_schema || ''')');
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_SCHEMA', old_value => l_old_schema, value => l_schema);
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
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_old_schema, value => l_data_ts);
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_TS', value => l_data_ts);
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_DATA', value => l_data_ts);
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_GLS', value => l_gls_ts);
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_USERS', value => l_users_ts);
  if l_users_ts <> 'USERS' then
    dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => 'USERS', value => l_users_ts);
  end if;
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_TEMP', value => l_temp_ts);
  if l_temp_ts <> 'TEMP' then
    dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => 'TEMP', value => l_temp_ts);
  end if;
  dbms_datapump.set_parameter(handle => h1, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.data_filter(handle => h1, name => 'INCLUDE_ROWS', value => 0);
  dbms_datapump.metadata_transform(handle => h1, name => 'OID', value => 0);
  dbms_datapump.metadata_filter(handle => h1, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''OBJECT_GRANT'',''AUDIT_OBJ'',''TABLE_DATA'')');
  dbms_datapump.metadata_filter(handle => h1, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');
  dbms_datapump.start_job(handle => h1, skip_current => 0, abort_step => 0);
  dbms_datapump.detach(handle => h1);
end;
/
