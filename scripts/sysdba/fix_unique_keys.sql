/*
*/
set serveroutput on size unlimited echo off

define owner=&1

PROMPT Disabling PKs/UKs...
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || c.owner || '"."' || c.table_name || '"' as table_name, '"' || c.constraint_name || '"' as constraint_name, c.constraint_type
            FROM dba_constraints c, dba_tables t
            WHERE regexp_like(t.owner, '^&owner.$', 'i')
              AND t.iot_type is null
              AND c.owner = t.owner
              AND c.table_name = t.table_name
              AND t.table_name not in (SELECT queue_table FROM dba_queues WHERE owner = t.owner)
              AND c.constraint_type in ('P', 'U')
              AND c.status = 'ENABLED') loop
    begin
      if x.constraint_type = 'P' then
        execute immediate 'ALTER TABLE ' || x.table_name || ' DISABLE CONSTRAINT ' || x.constraint_name || ' CASCADE DROP INDEX';
      else
        execute immediate 'ALTER TABLE ' || x.table_name || ' DISABLE CONSTRAINT ' || x.constraint_name || ' DROP INDEX';
      end if;
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
PROMPT Enabling PKs/UKs...
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || c.owner || '"."' || c.table_name || '"' as table_name, '"' || c.constraint_name || '"' as constraint_name
            FROM dba_constraints c, dba_tables t
            WHERE regexp_like(t.owner, '^&owner.$', 'i')
              AND t.iot_type is null
              AND c.owner = t.owner
              AND c.table_name = t.table_name
              AND t.table_name not in (SELECT queue_table FROM dba_queues WHERE owner = t.owner)
              AND c.constraint_type in ('P', 'U')
              AND c.status = 'DISABLED') loop
    begin
      execute immediate 'ALTER TABLE ' || x.table_name || ' ENABLE CONSTRAINT ' || x.constraint_name;
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
