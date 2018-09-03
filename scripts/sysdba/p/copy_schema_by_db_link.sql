/*
*/
set serveroutput on timing on

define schema=&1
define db_link=&2

set termout off
column scn new_value scn
SELECT min(current_scn) as scn FROM gv$database@&db_link;
set termout on

whenever sqlerror exit failure
begin
  if length('&scn') = 0 then
    raise_application_error(-20001, 'DB Link is not working or SCN cannot be received from source database');
  end if;
end;
/

spool sync_&schema._from_&db_link.-&scn..log

declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM dba_tables
            WHERE owner = upper('&schema')
              AND temporary = 'N'
              AND num_rows = 0
            ORDER BY 1)
  loop
    l_SQL := 'INSERT INTO "' || t.owner || '"."' || t.table_name || '" SELECT * FROM "' || t.owner || '"."' || t.table_name || '"@&db_link AS OF SCN :scn';
    begin
      dbms_output.put_line(l_SQL || ';');
      dbms_application_info.set_client_info(t.owner || '.' || t.table_name);
      execute immediate l_SQL using &scn;
      commit;
    exception when others then
      dbms_output.put_line(l_SQL || ': ' || SQLERRM);
    end;
  end loop;
end;
/

spool off
