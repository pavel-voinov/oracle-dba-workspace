/*
*/
set serveroutput on size unlimited timing on

ACCEPT table_name DEFAULT '.*' PROMPT "Table name [all, if not specified]: "

PROMPT Lock statistics for table(s) '&table_name' in current schema

begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM all_tables
            WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA') and regexp_like(table_name, '^&table_name.$', 'i')
            ORDER BY 2)
  loop
    dbms_output.put_line(t.owner || '.' || t.table_name);
    dbms_stats.lock_table_stats(ownname => t.owner, tabname => t.table_name);
  end loop;
end;
/
