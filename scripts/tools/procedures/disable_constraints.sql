/*
*/
CREATE OR REPLACE PROCEDURE disable_constraints (
  p_TableName      varchar2,
  p_Schema         varchar2,
  p_ConstraintType varchar2 default null)
as
begin
  DBMS_APPLICATION_INFO.SET_MODULE('TOOLS', 'disable_constraints');

  dbms_output.enable(null);
  for x in (SELECT '"' || c.owner || '"."' || c.table_name || '"' as table_name, c.constraint_name
            FROM all_constraints c, all_tables t
            WHERE t.owner = nvl(upper(p_Schema), sys_context('USERENV', 'CURRENT_SCHEMA'))
              AND (p_TableName is null or t.table_name = upper(p_TableName))
              AND t.iot_name is null
              AND c.owner = t.owner
              AND c.table_name = t.table_name
              AND ((p_ConstraintType is null and c.constraint_type IN ('U', 'R', 'P', 'C')) or c.constraint_type = upper(p_ConstraintType))
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

  DBMS_APPLICATION_INFO.SET_MODULE(null, null);
end disable_constraints;
/
