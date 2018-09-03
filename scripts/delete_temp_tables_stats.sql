set serveroutput on size unlimited

begin
  for t in (select owner, table_name
            from all_tables
            where owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND temporary = 'Y')
  loop
    dbms_stats.delete_table_stats(ownname => t.owner, tabname => t.table_name, force => true);
  end loop;
end;
/
