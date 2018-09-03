set serveroutput on size unlimited verify off timing off

begin
  for f in (SELECT 'DROP TYPE "' || owner || '"."' || object_name || '" FORCE' as sql_text
            FROM all_objects
            WHERE object_type = 'TYPE' AND owner = upper('&1') AND regexp_like(object_name, '^SYS(_PLSQL_|TP)')) loop
    execute immediate f.sql_text;
  end loop;
end;
/
