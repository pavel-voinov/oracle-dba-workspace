/*
*/
set serveroutput on size unlimited timing on

define schema=''

set termout off
column schema new_value schema
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as schema FROM dual;
set termout on

ACCEPT schema DEFAULT '&schema' PROMPT "Schema name. [&schema]: "
ACCEPT table_name DEFAULT '.*' PROMPT "Table name [all, if not specified]: "

PROMPT Lock statistics for table(s) '&table_name' in '&schema'

begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM dba_tables
            WHERE regexp_like(owner, '^&schema.$', 'i') and regexp_like(table_name, '^&table_name.$', 'i'))
  loop
    dbms_output.put_line(t.owner || '.' || t.table_name);
    dbms_stats.lock_table_stats(ownname => t.owner, tabname => t.table_name);
  end loop;
end;
/
