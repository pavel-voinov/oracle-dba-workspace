set serveroutput on size 1000000 buffer 1000000 verify off timing on scan on autotrace off

set term off

column p_reusefile new_value p_reusefile
column p_cluster_ok new_value p_cluster_ok
column p_version new_value p_version

SELECT decode(version, 10, '', ', cluster_ok => 0') as p_cluster_ok,
  decode(version, 10, '', ', reusefile => 1') as p_reusefile,
  version as p_version
FROM (SELECT to_number(substr(version, 1, instr(version, '.') - 1)) as version FROM v$instance)
/
set term on

declare
  l_handle     number;
  l_old_schema varchar2(30) := upper('&p_schema');
  l_schema     varchar2(30) := upper('&p_tgt_schema');
  l_dir        varchar2(30) := upper('&p_dir');
  l_dump       varchar2(255) := '&p_dump';
  l_job        varchar2(255) := '&p_job';
  l_log        varchar2(255) := '&p_log';
  l_parallel   integer := to_number(nvl('&p_parallel', '4'));
  l_tables     varchar2(32000) := '&p_tables';
  l_mode       varchar2(10) := 'SCHEMA';
  l_state      varchar2(255);

  cursor default_ts is
    SELECT default_tablespace, temporary_tablespace
    FROM dba_users
    WHERE username = upper(l_schema);

  l_ts         varchar(30);
  l_tmp_ts     varchar(30);

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
  dbms_output.enable(null);

  l_schema := regexp_replace(replace(trim(l_schema), ' '), '(^|,)?([^,]+)(,|$)?', '\1''\2''\3');
  if l_tables is not null then
    l_mode := 'TABLE';
    l_tables := regexp_replace(replace(trim(l_tables), ' '), '(^|,)?([^,]+)(,|$)?', '\1''\2''\3');
  end if;

  open default_ts;
  fetch default_ts into l_ts, l_tmp_ts;
  close default_ts;

dbms_output.put_line(l_schema || ' - ' || l_ts || '-' || l_tmp_ts);

/*
  l_handle := dbms_datapump.open (operation => 'IMPORT', job_mode => l_mode, job_name => l_job, version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => l_handle, degree => l_parallel);
  dbms_datapump.add_file(handle => l_handle, filename => l_log, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(''' || l_old_schema || ''')');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_SCHEMA', old_value => l_old_schema, value => l_schema);
  if exists_ts(l_schema || '_DATA') then
    l_ts := l_schema || '_DATA';
  end if;
  l_ts := nvl(l_ts, 'USERS');
  l_tmp_ts := nvl(l_tmp_ts, 'TEMP');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema, value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_TS', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_DATA', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_INDEX', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_IDX', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_LOG', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_DOC', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_LOB', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_GLS', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => l_old_schema || '_USERS', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'NEXT_GEN_ASM1', value => l_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'TEMP', value => l_tmp_ts);
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => '%', value => l_ts);

  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'TABLE_EXISTS_ACTION', value => 'SKIP');
  dbms_datapump.set_parameter(handle => l_handle, name => 'SKIP_UNUSABLE_INDEXES', value => 0);
  dbms_datapump.metadata_transform(handle => l_handle, name => 'OID', value => 0);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'')');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');
  if '&p_content' in ('ALL', 'METADATA_ONLY') then
    dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  else
    dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 0);
  end if;

  dbms_datapump.log_entry(handle => l_handle, message => 'Import started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);

  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0 &p_cluster_ok);
  if '&p_run_as_job' = 'Y' then
    dbms_datapump.detach(handle => l_handle);
  else
    dbms_datapump.wait_for_job(handle => l_handle, job_state => l_state);
  end if;
*/
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
