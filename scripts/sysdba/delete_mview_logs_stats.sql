define p_owner=&1

begin
  for t in (SELECT log_owner, log_table
            FROM dba_mview_logs
            WHERE log_owner = upper('&p_owner'))
  loop
    dbms_stats.delete_table_stats(ownname => t.log_owner, tabname => t.log_table, force => true);
    dbms_stats.lock_table_stats(ownname => t.log_owner, tabname => t.log_table);
  end loop;
end;
/
