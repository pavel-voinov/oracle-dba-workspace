/*
*/
begin
  execute immediate 'ALTER SYSTEM SET dispatchers=''(PROTOCOL=TCP)(SERVICE=' || sys_context('USERENV', 'DB_UNIQUE_NAME') || 'XDB)'' SCOPE=BOTH SID=''*''';
end;
/
set serveroutput on size unlimited

exec dbms_xdb.sethttpport(0);
exec dbms_xdb.sethttpport(8080);
