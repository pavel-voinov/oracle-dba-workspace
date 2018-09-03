/*
*/
set serveroutput on size unlimited buffer 100000 verify off timing off scan on

define p_schemas=&1
define p_dir=&2
define p_parallelism=&3

declare
  l_handle  integer;
  l_dir     varchar2(30);
  l_schemas varchar2(1024) := upper('&p_schemas');
  l_x_schemas varchar2(1024);
  l_dump    varchar2(255);
  l_job     varchar2(255);
  l_log     varchar2(255);
  l_scn     integer;
  l_tmp     integer;
  i         integer;
  l_ts      varchar2(8);
  l_tmp2    varchar2(255);

  cursor c_Schemas is
    SELECT listagg('''' || username || '''', ',') within group (order by username)
    FROM dba_users
    WHERE regexp_like(username, '^(' || replace(l_schemas, ',', '|') || ')$');

begin
  i := instr(l_schemas, ',');
  l_ts := to_char(systimestamp, 'YYYYMMDD');
  l_tmp := replace(upper(sys_context('USERENV', 'DB_DOMAIN')), 'INT.THOMSONREUTERS.COM');
  if l_tmp2 is null then
    l_tmp2 := sys_context('USERENV', 'DB_NAME');
  else
    l_tmp2 := sys_context('USERENV', 'DB_NAME') || '_' || l_tmp;
  end if;
  if i > 0 then
    l_dump := upper(l_tmp2) || '_' || substr(l_schemas, 1, i - 1) || '_' || l_ts;
    l_job := 'EXP_' || substr(l_schemas, 1, i - 1) || '_' || l_ts;
  else
    l_dump := upper(l_tmp) || '_' || l_schemas || '_' || l_ts;
    l_job := 'EXP_' || l_schemas || '_' || l_ts;
  end if;
  
  l_log := l_dump || '.log';
  l_dump := l_dump || '_%U.dmp';
  l_dir := nvl(upper('&p_dir'), 'DATAPUMP_DIR');

  dbms_output.enable(null);

  open c_schemas;
  fetch c_schemas into l_x_schemas;
  close c_schemas;

  SELECT count(*) INTO l_tmp
  FROM dba_directories
  WHERE directory_name = upper(l_dir);

  if l_tmp = 0 then
    raise_application_error(-20000, 'Oracle directory [' || l_dir || '] is not found');
  end if;

  SELECT timestamp_to_scn(systimestamp) INTO l_scn FROM dual;

  l_handle := dbms_datapump.open (operation => 'EXPORT', job_mode => 'SCHEMA', job_name => l_job, version => 'COMPATIBLE');

  dbms_datapump.set_parallel(handle => l_handle, degree => 2);

  dbms_datapump.add_file(handle => l_handle, filename => l_log, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE, reusefile => 1);
  dbms_datapump.add_file(handle => l_handle, filename => l_dump, directory => l_dir, filetype => dbms_datapump.KU$_FILE_TYPE_DUMP_FILE, filesize => '8192M', reusefile => 1);

  dbms_datapump.set_parameter(handle => l_handle, name => 'KEEP_MASTER', value => 0);
  dbms_datapump.set_parameter(handle => l_handle, name => 'DATA_ACCESS_METHOD', value => 'AUTOMATIC');
  dbms_datapump.set_parameter(handle => l_handle, name => 'INCLUDE_METADATA', value => 1);
  dbms_datapump.set_parameter(handle => l_handle, name => 'FLASHBACK_SCN', value => l_scn);
  dbms_datapump.set_parameter(handle => l_handle, name => 'COMPRESSION', value => 'ALL');

  dbms_datapump.metadata_filter(handle => l_handle, name => 'SCHEMA_EXPR', value => 'IN(' || l_x_schemas || ')');
  dbms_datapump.metadata_filter(handle => l_handle, name => 'EXCLUDE_PATH_EXPR', value => 'IN(''AUDIT_OBJ'')');
  -- ignore special db objects
  dbms_datapump.metadata_filter(handle => l_handle, name => 'NAME_EXPR', value => 'NOT LIKE ''SYS_PLSQL_%''', object_type => 'TYPE');

  dbms_datapump.log_entry(handle => l_handle, message => 'Export started at ' || to_char(systimestamp, 'DD.MM.YYYY HH24:MI:SS TZH:TZM'), log_file_only => 1);
  dbms_datapump.log_entry(handle => l_handle, message => 'SCN: ' || l_scn, log_file_only => 1);

  dbms_datapump.start_job(handle => l_handle, skip_current => 0, abort_step => 0, cluster_ok => 0);
  dbms_datapump.detach(handle => l_handle);
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

undefine p_dir
undefine p_schemas
undefine p_paralellism
