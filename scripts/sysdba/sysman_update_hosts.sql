set serveroutput on size unlimited
declare
  l_SQL varchar2(32000);
  l_cnt number;
begin
  dbms_output.enable(null);
  for x in (select '"' || table_name || '"' as table_name, '"' || column_name || '"' as column_name
            from dba_tab_columns
            where owner = 'SYSMAN'
--              and column_name like '%HOST%'
              and data_type = 'VARCHAR2'
            order by table_name)
  loop
    l_SQL := 'SELECT count(*) as cnt FROM ' || x.table_name || ' WHERE instr(' || x.column_name || ', upper(:hostname)) > 0';
    begin
      execute immediate l_SQL into l_cnt using 'c055dkhengsnp';
      if l_cnt > 0 then
        l_SQL := 'SELECT * FROM ' || x.table_name || ' WHERE ' || x.column_name || ' <> lower(' || x.column_name || ')';
        dbms_output.put_line(l_SQL || ';');
        l_SQL := 'UPDATE ' || x.table_name || ' SET ' || x.column_name || ' = lower(' || x.column_name || ') WHERE ' || x.column_name || ' <> lower(' || x.column_name || ')';
        dbms_output.put_line(l_SQL || ';');
--        execute immediate l_SQL;
      end if;
    exception when others then
      dbms_output.put_line(l_SQL);
      dbms_output.put_line(SQLERRM);
    end;
    commit;
  end loop;
end;
/

