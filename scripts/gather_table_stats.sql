/*
*/
set serveroutput on size unlimited timing on

ACCEPT table_name DEFAULT '.*' PROMPT "Table name [all, if not specified]: "
ACCEPT method_opt DEFAULT 'FOR ALL COLUMNS SIZE AUTO' PROMPT "Gather method options [FOR ALL COLUMNS SIZE AUTO]: "

PROMPT Gather statistics for table(s) '&table_name' in current schema

begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM all_tables
            WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND regexp_like(table_name, '^(' || replace('&table_name', ',', '|') || ')$', 'i')
              AND iot_name is null
              AND temporary = 'N'
            MINUS
            SELECT owner, table_name
            FROM all_external_tables)
  loop
    dbms_output.put_line(t.owner || '.' || t.table_name);
    dbms_stats.gather_table_stats(
      ownname => t.owner,
      tabname => t.table_name,
      estimate_percent => dbms_stats.auto_sample_size,
      method_opt => '&&method_opt',
      cascade => true,
      degree => dbms_stats.auto_degree,
      force => true);
  end loop;
end;
/

undefine table_name
undefine method_opt
