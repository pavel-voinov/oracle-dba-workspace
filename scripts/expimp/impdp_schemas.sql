set serveroutput on size 1000000 buffer 1000000 verify off timing on scan on autotrace off

define p_schema=&1
define p_dir=&2
define p_dumpfile=&3

declare
  l_handle     number;
  l_schema     varchar2(1024) := upper('&p_schema');
  l_dir        varchar2(30) := upper('&p_dir');
  l_dump       varchar2(255) := '&p_dumpfile';
  l_job        varchar2(255);

begin
  l_schema := replace(trim(l_schema), ' ');
  if instr(l_schema, ',') > 0 then
    l_job := 'IMP_' || substr(l_schema, 1, instr(l_schema, ',') - 1) || '_' || to_char(systimestamp, 'YYYYMMDD');
  else
    l_job := 'IMP_' || l_schema || '_' || to_char(systimestamp, 'YYYYMMDD');
  end if;

  l_schema := regexp_replace(l_schema, '(^|,)?([^,]+)(,|$)?', '\1''\2''\3');

  l_handle := dbms_datapump.open (operation => 'IMPORT', job_mode => 'SCHEMA', job_name => l_job, version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => l_handle, degree => 4);
  dbms_datapump.add_file(handle => l_handle, filename => l_job || '.log', directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(' || l_schema || ')');

  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'GG_EDITORIAL_TS', value => 'GG_EDITORIAL_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'GG_EDITORIAL_INDEX', value => 'GG_EDITORIAL_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'IDDB32_IDX', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'JPHARM_JN_INDEX', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'JPHARM_JN_LOB', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'JPHARM_LG_DATA', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'JPHARM_LG_LOB', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'JPHARM_MD_DATA', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'JPHARM_MD_LOB', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'JPHARM_SM_DATA', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'JPHARM_SM_LOB', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'MVLOGS', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'QUEST_DATA', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'REFLDR_DATA', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'REFLDR_INDEX', value => 'JPHARM_DATA');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_TABLESPACE', old_value => 'TOOLS', value => 'JPHARM_DATA');

  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.set_parameter(handle => l_handle, name => 'TABLE_EXISTS_ACTION', value => 'SKIP');
  dbms_datapump.set_parameter(handle => l_handle, name => 'SKIP_UNUSABLE_INDEXES', value => 0);
  dbms_datapump.metadata_transform(handle => l_handle, name => 'OID', value => 0);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'',''DB_LINK'',''JOB'',''GRANT'',''REFRESH_GROUP'',''MATERIALIZED_VIEW'',''MATERIALIZED_VIEW_LOG'',''DOMAIN_INDEX'')');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');

  dbms_datapump.log_entry(handle => l_handle, message => 'Import started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);

  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0, cluster_ok => 0);
  dbms_datapump.detach(handle => l_handle);
end;
/
