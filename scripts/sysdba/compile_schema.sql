/*
*/
set serveroutput on size unlimited verify off linesize 180

define p_schema=&1

begin
  dbms_output.enable(null);
  for s in (SELECT username
            FROM dba_users
            WHERE regexp_like(username, '^(' || replace('&p_schema', ',', '|') || ')$', 'i'))
  loop
    begin
      dbms_utility.compile_schema(s.username, false, true);
    exception when others then
      dbms_output.put(s.username || ': ' || SQLERRM);
    end;
  end loop;
end;
/
column owner format a30
column object_type format a30
column object_name format a30
column status format a10
PROMPT
PROMPT Remaining invalid objects:
SELECT owner, object_type, object_name, status
FROM dba_objects
WHERE regexp_like(owner, '^(' || replace('&p_schema', ',', '|') || ')$', 'i')
   AND status <> 'VALID'
ORDER BY 1, 2, 3
/
