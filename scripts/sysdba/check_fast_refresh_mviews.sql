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
            WHERE owner = upper('&schema') AND refresh_method IN ('FORCE', 'FAST'))
  loop
    dbms_mview.explain_mview(mv => t.mview_name, msg_array => l_mv_capabilities_table);
  end loop;

  open :c for
    SELECT owner, mview_name
    FROM dba_mviews m, table(l_mv_capabilities_table) c
    WHERE m.owner = upper('&schema') and m.refresh_method = 'FAST'
      AND c.mvowner = m.owner
      AND m.mview_name = c.mvname 
      AND c.capability_name = 'REFRESH_FAST'
      AND c.possible = 'N';
end;
/

column owner format a30 heading "Owner" 
column mview_name format a30 heading "Name" 

TTITLE "Materilized views with FAST refresh option which have to be refreshed in COMPLETE mode first"
PRINT :c

undefine schema
