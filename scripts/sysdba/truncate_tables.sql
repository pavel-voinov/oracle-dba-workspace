set serveroutput on size unlimited echo off

define p_owner=&1
define p_table=&2

declare
  l_schema constant varchar2(30) := upper('&p_owner');

  type tstr is table of varchar2(32);
  l_tables tstr;

  cursor c_Tables is
    SELECT table_name
    FROM dba_tables
    WHERE owner = l_schema
      AND table_name like upper('&p_table')
      AND temporary = 'N'
    MINUS
    SELECT table_name
    FROM dba_external_tables
    WHERE owner = l_schema;

  procedure disable_foreign_keys(
    p_TableName    varchar2 default null,
    p_IgnoreErrors boolean default false,
    p_Schema       varchar2 default null)
  as
  begin
    for x in (SELECT '"' || fk.owner || '"."' || fk.table_name || '"' as table_name, fk.constraint_name
              FROM dba_constraints pk, dba_constraints fk
              WHERE pk.table_name = p_TableName AND
                pk.owner = p_Schema AND
                fk.owner = pk.owner AND
                fk.r_constraint_name = pk.constraint_name AND
                fk.status = 'ENABLED') loop
      begin
        execute immediate 'ALTER TABLE ' || x.table_name || ' MODIFY CONSTRAINT "' || x.constraint_name || '" DISABLE';
      exception
        when others then
          dbms_output.put_line(x.table_name || ': ' || SQLERRM);
          if not p_IgnoreErrors then
            raise;
          end if;
      end;
    end loop;
  end disable_foreign_keys;

  procedure disable_constraints(
    p_TableName      varchar2 default null,
    p_ConstraintType varchar2 default null,
    p_IgnoreErrors   boolean default false,
    p_Schema         varchar2 default null)
  as
  begin
    for x in (SELECT '"' || owner || '"."' || table_name || '"' as table_name, constraint_name, constraint_type
              FROM dba_constraints s
              WHERE table_name = p_TableName
                AND owner = p_Schema
                AND status = 'ENABLED'
                AND constraint_type IN ('U', 'R', 'P')
                AND not exists (SELECT null FROM dba_tables t WHERE t.owner = s.owner AND t.table_name = s.table_name AND s.constraint_type = 'P' AND iot_type is not null)
              ORDER BY decode(constraint_type, 'U', 0, 'R', 1, 2))
    loop
      begin
        execute immediate 'ALTER TABLE ' || x.table_name || ' MODIFY CONSTRAINT "' || x.constraint_name || '" DISABLE';
      exception
        when others then
          dbms_output.put_line(x.table_name || ': ' || SQLERRM);
          if not p_IgnoreErrors then
            raise;
          end if;
      end;
    end loop;
  end disable_constraints;

  procedure disable_triggers(
    p_TableName    varchar2 default null,
    p_IgnoreErrors boolean default false,
    p_Schema       varchar2 default null)
  as
  begin
    for x in (SELECT '"' || owner || '"."' || trigger_name || '"' as trigger_name
              FROM dba_triggers
              WHERE owner = p_Schema AND
                table_name = p_TableName AND
                status = 'ENABLED') loop
      begin
        execute immediate 'ALTER TRIGGER ' || x.trigger_name || ' DISABLE';
      exception
        when others then
          dbms_output.put_line(x.trigger_name || ': ' || SQLERRM);
          if not p_IgnoreErrors then
            raise;
          end if;
      end;
    end loop;
  end disable_triggers;

  procedure truncate_table(
    p_TableName varchar2,
    p_Schema    varchar2 default null)
  as
  begin
    for x in (SELECT '"' || owner || '"."' || table_name || '"' as table_name
              FROM dba_tables
              WHERE owner = p_Schema AND
                table_name = p_TableName) loop
      begin
        execute immediate 'TRUNCATE TABLE ' || x.table_name || ' PURGE MATERIALIZED VIEW LOG DROP ALL STORAGE';
      exception
        when others then
          dbms_output.put_line(x.table_name || ': ' || SQLERRM);
      end;
    end loop;
  end truncate_table;

begin
  dbms_output.enable(null);
  
  open c_Tables;
  fetch c_Tables bulk collect into l_tables;
  close c_Tables;

  for i in 1..l_tables.count
  loop
    disable_foreign_keys(p_TableName => l_tables(i), p_Schema => l_schema, p_IgnoreErrors => true);
  end loop;
  for i in 1..l_tables.count
  loop
    disable_constraints(p_TableName => l_tables(i), p_Schema => l_schema, p_IgnoreErrors => true);
  end loop;
  for i in 1..l_tables.count
  loop
    disable_triggers(p_TableName => l_tables(i), p_Schema => l_schema, p_IgnoreErrors => true);
  end loop;
  for i in 1..l_tables.count
  loop
    truncate_table(p_TableName => l_tables(i), p_Schema => l_schema);
  end loop;
end;
/
