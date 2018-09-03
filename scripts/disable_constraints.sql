set serveroutput on size 1000000 

PROMPT List of already disabled constraints:
SELECT owner, table_name, constraint_name
FROM all_constraints
WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
  AND status = 'DISABLED'
/
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || c.owner || '"."' || c.table_name || '"' as table_name, c.constraint_name
            FROM all_constraints c, all_tables t
            WHERE t.owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND t.iot_type is null
              AND c.owner = t.owner
              AND c.table_name = t.table_name
              AND c.constraint_type IN ('U', 'R', 'P')
              AND c.status = 'ENABLED'
            ORDER BY decode(c.constraint_type, 'U', 0, 'R', 1, 'P', 2, 'C', 3, 4))
  loop
    begin
      execute immediate 'ALTER TABLE ' || x.table_name || ' DISABLE CONSTRAINT "' || x.constraint_name || '"';
    exception
      when others then
        dbms_output.put_line(x.table_name || ' - ' || x.constraint_name || ': ' || SQLERRM);
    end;
  end loop;
end;
/
