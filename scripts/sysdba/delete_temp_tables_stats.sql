/*
*/
set serveroutput on size unlimited timing on

define schema=''

set termout off
column schema new_value schema
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as schema FROM dual;
set termout on

ACCEPT schema DEFAULT '&schema' PROMPT "Schema name. [&schema]: "

begin
  for t in (select owner, table_name
            from dba_tables
            where owner = '&schema'
              AND temporary = 'Y')
  loop
    dbms_stats.delete_table_stats(ownname => t.owner, tabname => t.table_name, force => true);
  end loop;
end;
/
