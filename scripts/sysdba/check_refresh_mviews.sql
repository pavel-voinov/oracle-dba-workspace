/*
*/
set serveroutput on size unlimited echo off verify off timing off linesize 180

define schema=&1

variable c REFCURSOR;

declare
  l_mv_capabilities_table ExplainMVArrayType;
begin
  for t in (SELECT '"' || owner || '"."' || mview_name || '"' as mview_name
            FROM dba_mviews
            WHERE owner = upper('&schema') AND refresh_method <> 'FAST')
  loop
    dbms_mview.explain_mview(mv => t.mview_name, msg_array => l_mv_capabilities_table);
  end loop;

  open :c for
    SELECT m.owner, m.mview_name, c.capability_name, c.possible, m.refresh_method, m.refresh_mode
    FROM dba_mviews m, table(l_mv_capabilities_table) c
    WHERE m.owner = upper('&schema')
--      AND m.refresh_method <> 'FAST'
      AND c.mvowner = m.owner
      AND m.mview_name = c.mvname
      AND c.capability_name like 'REFRESH%'
--      AND c.capability_name = decode(m.refresh_method, 'FAST', 'REFRESH_FAST', 'COMPLETE', 'REFRESH_COMPLETE', 'REFRESH_' || m.refresh_method)
--      AND c.possible = 'F'
    ORDER BY m.owner, m.mview_name, c.capability_name;
end;
/

column owner format a30 heading "Owner"
column mview_name format a30 heading "Name"
column capability_name format a30 heading "Capability"

TTITLE "Materilized views with not possible to do refresh in according to it refresh option"
PRINT :c

undefine schema
