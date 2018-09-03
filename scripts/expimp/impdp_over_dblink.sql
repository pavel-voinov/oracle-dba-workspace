set serveroutput on size 1000000 buffer 1000000 verify off timing on scan on autotrace off

declare
  l_handle     number;
begin
  l_handle := dbms_datapump.open(operation => 'IMPORT', job_mode => 'SCHEMA', remote_link => 'STAGING.QA.EDC', job_name => 'IMP_TEST', version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => l_handle, degree => 1); 
  dbms_datapump.add_file(handle => l_handle, filename => 'IMP_TEST.log', directory => 'DATAPUMP_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(''TEST'')');
  dbms_datapump.set_parameter(handle => l_handle, name => 'ESTIMATE', value => 'BLOCKS');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.set_parameter(handle => l_handle, name => 'TABLE_EXISTS_ACTION', value => 'REPLACE');
  dbms_datapump.set_parameter(handle => l_handle, name => 'SKIP_UNUSABLE_INDEXES', value => 0);
  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0);
  dbms_datapump.detach(handle => l_handle);
end;
/
