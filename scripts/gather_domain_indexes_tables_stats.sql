begin
  for t in (SELECT table_name
            FROM user_tables
            WHERE regexp_like(table_name, '(' || (select listagg (index_name, '|') within group (order by index_name)
                                                  from user_indexes
                                                  where index_type = 'DOMAIN' and ityp_owner = 'C$MDLICHEM70' and ityp_name = 'MXIXMDL') || ')'))
  loop
    dbms_stats.unlock_table_stats(ownname => user, tabname => t.table_name);
    dbms_stats.gather_table_stats(ownname => user, tabname => t.table_name, estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, cascade => true);
  end loop;
end;
/
