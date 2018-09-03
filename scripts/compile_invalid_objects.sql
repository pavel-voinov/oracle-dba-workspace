set verify off

declare
  l_owner varchar2(30) := sys_context('USERENV', 'CURRENT_SCHEMA');
  l_last integer := -1;
  l_now integer;

  function do_compile return integer as
    l_cnt integer;
  begin
    for x in (SELECT lower(object_name) as object_name, lower(object_type) as object_type,
                'ALTER ' || replace(object_type, ' BODY') || ' ' || l_owner || '.' || object_name || ' COMPILE ' ||
                decode(object_type, 'PACKAGE BODY', 'BODY', 'TYPE BODY', 'BODY', '') as sql_text
              FROM all_objects
              WHERE owner = l_owner AND
                status = 'INVALID' AND
                object_type IN ('PACKAGE', 'PACKAGE BODY', 'TYPE', 'TYPE BODY', 'PROCEDURE', 'FUNCTION', 'VIEW', 'SYNONYM', 'MATERIALIZED VIEW', 'TRIGGER')
              ORDER BY decode(object_type, 'TYPE', 0, 'PACKAGE', 1, 2), object_name) LOOP
      begin
        execute immediate x.sql_text;
      exception when others then
        dbms_output.put(x.object_type || ' - ' || x.object_name || ':');
        dbms_output.put_line(SQLERRM);
      end;
    end loop;

    SELECT count(*) into l_cnt FROM all_objects WHERE owner = l_owner AND status = 'INVALID';

    return l_cnt;
  end;
begin
  dbms_output.enable(null);
  loop
    l_now := do_compile();
    dbms_output.put_line(lpad('-', 60, '-'));
    dbms_output.put_line('Compile invalid objects. Count of invalid objects: ' || l_now);
    dbms_output.put_line(lpad('-', 60, '-'));
    exit when l_now = 0 or l_now = l_last;
    l_last := l_now;
  end loop;
  dbms_output.put_line('Count of remain invalid objects: ' || l_now);
end;
/
