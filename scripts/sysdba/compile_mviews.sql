/*
*/
set serveroutput on size unlimited echo off timing off

set termout off
column p_schema new_value p_schema
SELECT upper('&1') as p_schema FROM dual;
set termout on

column cnt heading "Count of NEEDS_COMPILE mviews"
PROMPT Count of not-VALID mviews before compile

set heading off
SELECT count(*) as cnt
FROM dba_mviews
WHERE owner = upper('&p_schema')
  AND compile_state <> 'VALID';

set timing on

begin
  dbms_output.enable(null);
  for t in (SELECT '"' || owner || '"."' || mview_name || '"' as mview_name
            FROM dba_mviews
            WHERE owner = upper('&p_schema')
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

PROMPT After compile
column owner format a30 heading "Owner"
column mview_name format a30 heading "Name"
column compile_state format a30 heading "Compilation state"
SELECT owner, mview_name, compile_state
FROM dba_mviews
WHERE owner = upper('&p_schema')
  AND compile_state <> 'VALID';

