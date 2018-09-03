/*
*/
CREATE OR REPLACE PROCEDURE enable_triggers (
  p_TableName varchar2 default null,
  p_Schema    varchar2 default null
)
as
begin
  for x in (SELECT owner || '.' || trigger_name as trigger_name
            FROM all_triggers
            WHERE (p_TableName is null or table_name = upper(p_TableName))
              AND owner = nvl(upper(p_Schema), sys_context('USERENV', 'CURRENT_SCHEMA'))
              AND status = 'DISABLED')
  loop
    begin
      execute immediate 'ALTER TRIGGER ' || x.trigger_name || ' ENABLE';
    exception
      when others then
        print(x.trigger_name || ': ' || SQLERRM);
    end;
  end loop;
end enable_triggers;
/
