set serveroutput on size unlimited buffer 100000 verify off timing on scan on

declare
  h1           number;
  l_src_schema varchar2(30) := upper('&1');
  l_dst_schema varchar2(30) := upper('&2');
  l_dump       varchar2(255);
  l_state      varchar2(4000);

  l_data_ts    varchar(30);
  l_users_ts   varchar(30);
  l_gls_ts     varchar(30);
  l_temp_ts    varchar(30);
  l_ts         varchar(30);
  l_tmp_ts     varchar(30);

  cursor default_ts is
    SELECT default_tablespace, temporary_tablespace
    FROM dba_users
    WHERE username = l_dst_schema;

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
  l_dump := upper(sys_context('USERENV', 'DB_NAME')) || '_' || l_src_schema || '_' || to_char(systimestamp, 'YYYYMMDD');

  h1 := dbms_datapump.open (operation => 'EXPORT', job_mode => 'SCHEMA', job_name => 'EXPORT_' || l_src_schema || '_' || to_char(systimestamp, 'YYYYMMDD'), version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => h1, degree => 1);
  dbms_datapump.add_file(handle => h1, filename => l_dump || '.log', directory => 'DATAPUMP_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => h1, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => h1, filename => l_dump || '_%U.dmp', directory => 'DATAPUMP_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE, filesize => '4G');
  dbms_datapump.metadata_filter(handle => h1, name => 'SCHEMA_EXPR', value => 'IN(''' || l_src_schema || ''')');
  dbms_datapump.set_parameter(handle => h1, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => h1, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.metadata_filter(handle => h1, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''OBJECT_GRANT'',''JOB'',''DB_LINK'',''STATISTICS'',''DOMAIN_INDEX'',''AUDIT_OBJ'')');
  dbms_datapump.metadata_filter(handle => h1, name => 'NAME_EXPR',
    value => 'NOT IN(''JCHEMPROPERTIES'',''JCHEMPROPERTIES_CR'',''JC_IDX_PROPERTY'',''JC_IDX_PROPERTY'',''CHEM_STRUCTS_I_JCHEM'',''MD_STRUCTS_I_JCHEM'',''MD_M_STRUCTS_I_J'',''CHEM_STRUCTS_I_JCHEM_JCX'',''CHEM_STRUCTS_I_JCHEM_JCX_UL'',''MD_STRUCTS_I_JCHEM_JCX'',''MD_STRUCTS_I_JCHEM_JCX_UL'',''MD_M_STRUCTS_I_J_JCX'',''MD_M_STRUCTS_I_J_JCX_UL'',''CHEMSTRUCTS_OLD'',''MDMSTRUCTS_OLD'',''MDUSERSTRUCTS_OLD'',''MD_USER_STRUCTS_IDS'',''MD_USER_STRUCTS_BAD'',''MD_MODEL_STRUCTS_IDS'',''MD_MODEL_STRUCTS_BAD'',''LISTCLOBREPORTS_NEW'',''LISTSTRUCTS_NEW'')', object_path => 'SCHEMA_EXPORT/TABLE');
  dbms_datapump.metadata_filter(handle => h1, name => 'NAME_EXPR', value => 'NOT IN(''CHEMSI_I_INCHI_MAIN'')', object_type => 'INDEX');
  dbms_datapump.metadata_filter(handle => h1, name => 'NAME_EXPR',
    value => 'NOT IN(''CHEM_STRUCTS_I_JCHEM_JCX_SQ'',''CHEM_STRUCTS_I_JCHEM_JCX_USQ'',''MD_STRUCTS_I_JCHEM_JCX_SQ'',''MD_STRUCTS_I_JCHEM_JCX_USQ'',''MD_M_STRUCTS_I_J_JCX_SQ'',''MD_M_STRUCTS_I_J_JCX_USQ'')',
    object_type => 'SEQUENCE');
  dbms_datapump.metadata_filter(handle => h1, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');

  dbms_datapump.log_entry(handle => h1, message => 'Export started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);
  dbms_datapump.log_entry(handle => h1, message => 'Job handle: ' || h1, log_file_only => 1);

  dbms_datapump.start_job(handle => h1, skip_current => 0, abort_step => 0);
  dbms_datapump.wait_for_job(handle => h1, job_state => l_state);

  open default_ts;
  fetch default_ts into l_ts, l_tmp_ts;
  close default_ts;

  l_data_ts := nvl(l_ts, 'USERS');
  l_users_ts := nvl(l_ts, 'USERS');
  l_gls_ts := nvl(l_ts, 'USERS');
  l_temp_ts := nvl(l_tmp_ts, 'TEMP');

  h1 := dbms_datapump.open (operation => 'IMPORT', job_mode => 'SCHEMA', job_name => 'IMPORT_' || l_dst_schema, version => 'COMPATIBLE');
  dbms_datapump.set_parallel(handle => h1, degree => 1);
  dbms_datapump.add_file(handle => h1, filename => 'IMPORT_' || l_dst_schema || '.log', directory => 'DATAPUMP_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);
  dbms_datapump.set_parameter(handle => h1, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.add_file(handle => h1, filename => l_dump || '_%U.dmp', directory => 'DATAPUMP_DIR', filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE);
  dbms_datapump.metadata_filter(handle => h1, name => 'SCHEMA_EXPR', value => 'IN(''' || l_src_schema || ''')');
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_SCHEMA', old_value => l_src_schema, value => l_dst_schema);
  if exists_ts(l_dst_schema || '_DATA') then
    l_data_ts := l_dst_schema || '_DATA';
  end if;
  if exists_ts(l_dst_schema || '_USERS') then
    l_users_ts := l_dst_schema || '_USERS';
  end if;
  if exists_ts(l_dst_schema || '_GLS') then
    l_gls_ts := l_dst_schema || '_GLS';
  end if;
  if exists_ts(l_dst_schema || '_TEMP') then
    l_temp_ts := l_dst_schema || '_TEMP';
  end if;
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_src_schema, value => l_data_ts);
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_src_schema || '_TS', value => l_data_ts);
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_src_schema || '_DATA', value => l_data_ts);
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_src_schema || '_GLS', value => l_gls_ts);
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_src_schema || '_USERS', value => l_users_ts);
  if l_users_ts <> 'USERS' then
    dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => 'USERS', value => l_users_ts);
  end if;
  dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => l_src_schema || '_TEMP', value => l_temp_ts);
  if l_temp_ts <> 'TEMP' then
    dbms_datapump.metadata_remap(handle => h1, name => 'REMAP_TABLESPACE', old_value => 'TEMP', value => l_temp_ts);
  end if;
  dbms_datapump.set_parameter(handle => h1, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => h1, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.set_parameter(handle => h1, name => 'TABLE_EXISTS_ACTION', value => 'SKIP');
  dbms_datapump.set_parameter(handle => h1, name => 'SKIP_UNUSABLE_INDEXES', value => 0);
  dbms_datapump.metadata_transform(handle => h1, name => 'OID', value => 0);
  dbms_datapump.metadata_filter(handle => h1, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''OBJECT_GRANT'',''AUDIT_OBJ'')');
  dbms_datapump.metadata_filter(handle => h1, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');

  dbms_datapump.log_entry(handle => h1, message => 'Import started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS'), log_file_only => 1);
  dbms_datapump.log_entry(handle => h1, message => 'Job handle: ' || h1, log_file_only => 1);

  dbms_datapump.start_job(handle => h1, skip_current => 0, abort_step => 0);
  dbms_datapump.wait_for_job(handle => h1, job_state => l_state);
end;
/
