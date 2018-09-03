begin
  for x in (SELECT owner || '.' || trigger_name || '' as trigger_name
            FROM all_triggers
            WHERE --table_name = nvl(upper(p_TableName), table_name) AND
              owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND status = 'DISABLED') loop
    begin
      execute immediate 'ALTER TRIGGER ' || x.trigger_name || ' ENABLE';
    exception
      when others then
        dbms_output.put_line(x.trigger_name || ': ' || SQLERRM);
    end;
  end loop;
end;
/
