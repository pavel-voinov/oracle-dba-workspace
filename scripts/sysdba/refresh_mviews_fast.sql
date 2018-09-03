/*
*/
set serveroutput on size unlimited echo off verify off timing on

define p_schema=&1
define p_parallelism=&2

@@compile_mviews &p_schema

whenever sqlerror exit failure

declare
  l_mv_capabilities_table ExplainMVArrayType;
begin
  for t in (SELECT '"' || owner || '"."' || mview_name || '"' as mview_name
            FROM dba_mviews
            WHERE owner = upper('&p_schema'))
-- AND refresh_method = 'FAST')
  loop
    dbms_mview.explain_mview(mv => t.mview_name, msg_array => l_mv_capabilities_table);
  end loop;

  dbms_output.enable(null);

  for t in (SELECT '"' || owner || '"."' || mview_name || '"' as mview_name
            FROM dba_mviews m, table(l_mv_capabilities_table) c
            WHERE m.owner = upper('&p_schema')
--              AND m.refresh_method = 'FAST'
              AND c.mvowner = m.owner
              AND m.mview_name = c.mvname 
              AND c.capability_name = 'REFRESH_FAST'
              AND c.possible = 'N')
  loop
    begin
      dbms_application_info.set_client_info(t.mview_name);
      dbms_mview.refresh(list => t.mview_name, method => 'F', parallelism => to_number('&p_parallelism'));
    exception when others then
      begin
        dbms_mview.refresh(list => t.mview_name, method => 'C', parallelism => to_number('&p_parallelism'));
      exception when others then
        dbms_output.put_line(t.mview_name || ': ' || SQLERRM);
      end;
    end;
  end loop;
end;
/

undefine p_schema
undefine p_parallelism
