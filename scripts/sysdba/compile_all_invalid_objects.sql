set verify off

PROMPT Compile invalid objects if possible

declare
  l_last integer := -1;
  l_now integer;

  function do_compile return integer as
    l_cnt integer;
  begin
    for x in (SELECT lower(owner) as owner, lower(object_name) as object_name, lower(object_type) as object_type,
                'ALTER ' || replace(object_type, ' BODY') || ' ' || owner || '.' || object_name || ' COMPILE ' ||
                decode(object_type, 'PACKAGE BODY', 'BODY', 'TYPE BODY', 'BODY', '') as sql_text
              FROM all_objects
              WHERE status = 'INVALID' AND
                object_type IN ('PACKAGE', 'PACKAGE BODY', 'TYPE', 'TYPE BODY', 'PROCEDURE', 'FUNCTION', 'VIEW', 'SYNONYM', 'MATERIALIZED VIEW', 'TRIGGER')
              ORDER BY decode(object_type, 'TYPE', 0, 'PACKAGE', 1, 2), object_name) LOOP
      begin
        execute immediate x.sql_text;
      exception when others then
        dbms_output.put(x.object_type || ' - ' || x.owner || '.' || x.object_name || ':');
        dbms_output.put_line(SQLERRM);
      end;
    end loop;

    SELECT count(*) into l_cnt FROM all_objects WHERE status = 'INVALID';

    return l_cnt;
  end;
begin
  loop
    l_now := do_compile();
    exit when l_now = 0 or l_now = l_last;
    l_last := l_now;
  end loop;
end;
/
