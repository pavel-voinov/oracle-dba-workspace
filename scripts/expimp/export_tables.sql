set serveroutput on size unlimited verify off

declare
  l_handle NUMBER;
  l_schema varchar2(30) := upper('&1');
  l_dump  varchar2(4000) := upper('&2');
  l_tables varchar2(4000) := upper('&3');

  type TStringArray is table of varchar2(128);
  l_temp TStringArray;

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
      l_str := trim(regexp_substr(p_String, l_regexp, 1, i));
      exit when l_str is null;
      l_result.extend();
      l_result(i) := l_str;
      i := i + 1;
    end loop;

    return l_result;
  end str2array;

begin
  l_temp := str2array(l_tables);
  l_tables := null;
  for i in 1..l_temp.count loop
    if l_tables is not null then
      l_tables := l_tables || ',';
    end if;
    l_tables := l_tables || '''' || l_temp(i) || '''';
  end loop;

  l_handle := dbms_datapump.open (operation => 'EXPORT', job_mode => 'TABLE', job_name => 'EXPORT_' || l_schema || '_TABLES', version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => l_handle, degree => 1);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump || '.log', directory => 'DATA_PUMP_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump || '_%U.dmp', directory => 'DATA_PUMP_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE, filesize => '4G');
  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.set_parameter(handle => l_handle, name => 'ESTIMATE', value => 'BLOCKS');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(''' || l_schema || ''')');
--  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''OBJECT_GRANT'',''JOB'',''DB_LINK'',''STATISTICS'',''DOMAIN_INDEX'',''AUDIT_OBJ'')');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'')');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'IN(' || l_tables || ')');
--  dbms_datapump.data_filter(handle => l_handle, name => 'INCLUDE_ROWS', value => 1);
  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0);
  dbms_datapump.detach(handle => l_handle);
end;
/
