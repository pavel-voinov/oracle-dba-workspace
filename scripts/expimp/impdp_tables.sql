set serveroutput on size unlimited buffer 1000000 verify off timing on scan on autotrace off echo off

/*
Usage: @impdp_tables <Source schema> <Destination schema> <Dump file mask> <Tables list, delimited by comma, without any quotes and spaces>
Example:
@impdp_tables GENEGO FRENKEL EXPDP_MAINDB_GENEGO_20100412 GENE_DISS,NOTEDISS,NOTICEDISS,DIS_LINKS,DIS_LINK_NOTES
*/

declare
  l_handle   NUMBER;
  l_old_schema varchar2(30) := upper('&1');
  l_schema     varchar2(30) := upper('&2');
  l_dir        varchar2(30) := upper('&3');
  l_dump       varchar2(255) := '&4';
  l_tables     varchar2(32000) := upper('&5');
  l_job_name   varchar2(255);

  l_data_ts varchar(30);
  l_users_ts varchar(30);
  l_gls_ts varchar(30);
  l_temp_ts varchar(30);
  
  type TStringArray is table of varchar2(128);
  l_temp TStringArray;

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

  function str2array(p_String varchar2) return TStringArray as

    l_regexp varchar2(255);
    l_str    VARCHAR2(32000);
    i        NUMBER;
    l_result TStringArray;

  begin
    -- prepare open- and close- symbols for phrase and fixes final regexp
    l_regexp := '(\"[^\"]+\")|([^,]+)';

    l_result := TStringArray();
    i := 1;
    loop
      l_str := regexp_substr(p_String, l_regexp, 1, i);
      exit when l_str is null;
      l_result.extend();
      l_result(i) := l_str;
      i := i + 1;
    end loop;

    return l_result;
  end str2array;

begin
  if l_tables = '*' then
    l_tables := null;
  else
    l_temp := str2array(l_tables);
    l_tables := null;
    for i in 1..l_temp.count loop
      if l_tables is not null then
        l_tables := l_tables || ',';
      end if;
      l_tables := l_tables || '''' || l_temp(i) || '''';
    end loop;
  end if;

  open default_ts;
  fetch default_ts into l_ts, l_tmp_ts;
  close default_ts;

  l_data_ts := nvl(l_ts, 'USERS');
  l_users_ts := nvl(l_ts, 'USERS');
  l_gls_ts := nvl(l_ts, 'USERS');
  l_temp_ts := nvl(l_tmp_ts, 'TEMP');

  l_job_name := 'IMP_' || substr(l_schema, 1, 6) || '_TABS_' || to_char(sysdate, 'YYYYMMDDHH24MI');
  l_handle := dbms_datapump.open (operation => 'IMPORT', job_mode => 'TABLE', job_name => l_job_name, version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => l_handle, degree => 1);
  dbms_datapump.add_file(handle => l_handle, filename => l_job_name || '.log', directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
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
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_GLS', value => l_gls_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_USERS', value => l_users_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'USERS', value => l_users_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_TEMP', value => l_temp_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'TEMP', value => l_temp_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'MCMD65', value => l_data_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => '%', value => l_data_ts);
  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 0);
--  dbms_datapump.set_parameter(handle => l_handle, name => 'TABLE_EXISTS_ACTION', value => 'TRUNCATE');
  dbms_datapump.set_parameter(handle => l_handle, name => 'TABLE_EXISTS_ACTION', value => 'APPEND'); --REPLACE|SKIP
  dbms_datapump.set_parameter(handle => l_handle, name => 'SKIP_UNUSABLE_INDEXES', value => 0);
  dbms_datapump.metadata_transform(handle => l_handle, name => 'OID', value => 0);
--  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''GRANT'')');
  if l_tables is not null then
    dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'IN(' || l_tables || ')', object_path => 'SCHEMA_EXPORT/TABLE');
  end if;
  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0); 
  dbms_datapump.detach(handle => l_handle); 
end;
/
