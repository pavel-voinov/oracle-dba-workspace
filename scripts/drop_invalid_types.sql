set serveroutput on size unlimited verify off timing off

begin
  for f in (SELECT 'DROP TYPE ' || owner || '.' || object_name as sql_text
            FROM all_objects
            WHERE object_type = 'TYPE' AND owner = upper('&1') AND status = 'INVALID' AND object_name LIKE 'SYS_PLSQL_%') loop
    execute immediate f.sql_text;
  end loop;
end;
/
