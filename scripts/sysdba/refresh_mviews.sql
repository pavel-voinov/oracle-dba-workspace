/*
*/
set serveroutput on size unlimited echo on timing on

define p_schema=&1
define p_parallelism=&2

@@compile_mviews &p_schema
begin
  dbms_output.enable(null);
  for t in (SELECT '"' || owner || '"."' || mview_name || '"' as mview_name, staleness
            FROM dba_mviews
            WHERE owner = upper('&p_schema')
              AND staleness  <> 'FRESH'
            ORDER BY mview_name)
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
