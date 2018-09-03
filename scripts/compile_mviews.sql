/*
*/
set serveroutput on size unlimited echo off timing off

set termout off
column p_schema new_value p_schema
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as p_schema FROM dual;
set termout on

set heading off
PROMPT Count of not-VALID mviews before compile
SELECT count(*) as cnt
FROM all_mviews
WHERE owner = '&p_schema'
  AND compile_state <> 'VALID';

set timing on

begin
  dbms_output.enable(null);
  for t in (SELECT '"' || owner || '"."' || mview_name || '"' as mview_name
            FROM all_mviews
            WHERE owner = '&p_schema'
              AND compile_state <> 'VALID')
  loop
    begin
      execute immediate 'ALTER MATERIALIZED VIEW ' || t.mview_name || ' COMPILE';
    exception when others then
      dbms_output.put_line(t.mview_name || ': ' || SQLERRM);
    end;
  end loop;
end;
/

set timing off

set heading on
PROMPT List of not-VALID mviews after compile
column owner format a30 heading "Owner"
column mview_name format a30 heading "Name"
column compile_state format a30 heading "Compilation state"
SELECT owner, mview_name, compile_state
FROM all_mviews
WHERE owner = '&p_schema'
  AND compile_state <> 'VALID'
/

undefine p_schema
