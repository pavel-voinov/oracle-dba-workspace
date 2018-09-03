set serveroutput on size 1000000 buffer 1000000 verify off timing on scan on autotrace off

define p_schema=&1
define p_dir=&2
define p_dumpfile=&3
define p_src_schema=&4
define p_db_link=&5
-- TABLE_EXISTS_ACTION: REPLACE, TRUNCATE, APPEND
define p_tea=&6

declare
  l_handle     number;
  l_schema     varchar2(32) := upper('&p_schema');
  l_src_schema varchar2(32) := upper('&p_src_schema');
  l_dir        varchar2(30) := upper('&p_dir');
  l_dump       varchar2(255) := '&p_dumpfile';
  l_job        varchar2(255);
  l_state      varchar2(255);

  cursor default_ts is
    SELECT default_tablespace, temporary_tablespace
    FROM dba_users
    WHERE username = l_schema;

  cursor src_ts is
    SELECT distinct tablespace_name
    FROM dba_segments@&p_db_link
    WHERE owner = l_src_schema
    UNION
    SELECT tablespace_name
    FROM dba_ts_quotas@&p_db_link
    WHERE username = l_src_schema;

  l_ts varchar(30);
  l_tmp_ts varchar(30);

begin
  l_job := 'IMP_' || l_schema;

  open default_ts;
  fetch default_ts into l_ts, l_tmp_ts;
  close default_ts;

  l_ts := nvl(l_ts, l_schema || '_DATA');
  l_tmp_ts := nvl(l_tmp_ts, 'TEMP');

  l_handle := dbms_datapump.open (operation => 'IMPORT', job_mode => 'SCHEMA', job_name => l_job, version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => l_handle, degree => 8);
  dbms_datapump.add_file(handle => l_handle, filename => l_job || '.log', directory => 'DATAPUMP_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(''' || l_src_schema || ''')');
  if l_src_schema <> l_schema then
    dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_SCHEMA', old_value => l_src_schema, value => l_schema);
  end if;

  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.set_parameter(handle => l_handle, name => 'TABLE_EXISTS_ACTION', value => upper('&p_tea'));
  dbms_datapump.set_parameter(handle => l_handle, name => 'SKIP_UNUSABLE_INDEXES', value => 0);
  for t in src_ts
  loop
    if l_ts <> t.tablespace_name then
      dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => t.tablespace_name, value => l_ts);
    end if;
  end loop;
  dbms_datapump.metadata_transform(handle => l_handle, name => 'OID', value => 0);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'',''DB_LINK'',''JOB'',''OBJECT_GRANT'',''REFRESH_GROUP'',''DOMAIN_INDEX'')');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_EXPORT_%''', object_type => 'TABLE');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_IMPORT_%''', object_type => 'TABLE');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => '!=''PLAN_TABLE''', object_type => 'TABLE');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => '!=''SQLN_EXPLAIN_PLAN''', object_type => 'TABLE');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''PLSQL_PROFILER_%''', object_type => 'TABLE');

  dbms_datapump.log_entry(handle => l_handle, message => 'Import started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);

  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0, cluster_ok => 0);
  dbms_datapump.wait_for_job(handle => l_handle, job_state => l_state);
  dbms_output.put_line(l_state);
exception when others then
  dbms_output.put_line(l_state);
  dbms_output.put_line(SQLERRM);
  begin
    dbms_datapump.stop_job(handle => l_handle, immediate => 1, keep_master => 0);
  exception when others then
    null;
  end;
end;
/
