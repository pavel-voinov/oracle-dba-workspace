/*
*/
set serveroutput on size unlimited verify off linesize 180

begin
  dbms_output.enable(null);
  dbms_utility.compile_schema(sys_context('USERENV', 'CURRENT_SCHEMA'), false, true);
exception when others then
  dbms_output.put(SQLERRM);
end;
/
column object_type format a30
column object_name format a30
column status format a10
PROMPT
PROMPT Remaining invalid objects:
SELECT object_type, object_name, status
FROM all_objects
WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA') AND status <> 'VALID'
ORDER BY 1, 2
/
