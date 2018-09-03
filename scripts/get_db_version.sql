/*
*/
set serveroutput on size unlimited feedback off timing off

declare
  ver  varchar2(255);
  comp varchar2(255);
begin
  dbms_output.enable(null);
  dbms_utility.db_version(ver, comp);
  dbms_output.put_line('Database version: ' || ver);
  dbms_output.put_line('   compatibility: ' || comp);
end;
/
