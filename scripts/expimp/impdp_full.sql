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
  l_old_schema varchar2(30) := upper('&1');
  l_schema     varchar2(30) := upper('&2');
  l_dir        varchar2(30) := upper('&3');
  l_dump       varchar2(255) := '&4';
  l_job        varchar2(255);

begin
  l_job := 'IMPORT_' || l_schema || '_' || to_char(systimestamp, 'YYYYMMDD');

  l_handle := dbms_datapump.open (operation => 'IMPORT', job_mode => 'SCHEMA', job_name => l_job, version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => l_handle, degree => 1);
  dbms_datapump.add_file(handle => l_handle, filename => l_job || '.log', directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(''' || l_old_schema || ''')');
  dbms_datapump.metadata_remap(handle => l_handle, name => 'REMAP_SCHEMA', old_value => l_old_schema, value => l_schema);
  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.set_parameter(handle => l_handle, name => 'TABLE_EXISTS_ACTION', value => 'SKIP');
  dbms_datapump.set_parameter(handle => l_handle, name => 'SKIP_UNUSABLE_INDEXES', value => 0);
  dbms_datapump.metadata_transform(handle => l_handle, name => 'OID', value => 0);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'')');

  dbms_datapump.log_entry(handle => l_handle, message => 'Import started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);
  dbms_datapump.log_entry(handle => l_handle, message => 'Job handle: ' || l_handle, log_file_only => 1);

  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0 &p_cluster_ok);
  dbms_datapump.detach(handle => l_handle);
end;
/
