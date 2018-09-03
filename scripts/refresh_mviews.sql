/*
*/
set serveroutput on size unlimited echo on timing on

define p_parallelism=8

@@compile_mviews
declare
  l_failed boolean;
  l_parallelism number := to_number('&p_parallelism');

  table_does_not_exist exception;
  pragma exception_init(table_does_not_exist, -942);
  ora12034 exception;
  pragma exception_init(ora12034, -12034);
begin
  dbms_output.enable(null);
  for t in (SELECT '"' || owner || '"."' || mview_name || '"' as mview_name, refresh_method
            FROM all_mviews
            WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND staleness <> 'FRESH'
            ORDER BY mview_name)
  loop
    dbms_application_info.set_client_info(t.mview_name);
    if t.refresh_method in ('FORCE', 'FAST') then
      begin
        dbms_mview.refresh(list => t.mview_name, method => 'F', parallelism => l_parallelism);
        dbms_output.put_line(t.mview_name || ': refreshed in FAST mode');
        l_failed := false;
      exception
        when table_does_not_exist then
          dbms_output.put_line(t.mview_name || ': Probably needs to be recreated');
          l_failed := true;
        when ora12034 then
          dbms_output.put_line(t.mview_name || ': To be refreshed in complete mode');
          l_failed := true;
        when others then
          dbms_output.put_line(t.mview_name || ': ' || SQLERRM);
          l_failed := true;
      end;
    end if;
    if t.refresh_method not in ('FORCE', 'FAST') or l_failed then
      begin
        dbms_mview.refresh(list => t.mview_name, method => 'C', parallelism => l_parallelism);
        dbms_output.put_line(t.mview_name || ': refreshed in COMPLETE mode');
      exception
        when table_does_not_exist then
          dbms_output.put_line(t.mview_name || ': Call following command to recreate mview');
          dbms_output.put_line('@recreate_mview ' || t.mview_name);
        when others then
          dbms_output.put_line(t.mview_name || ': ' || SQLERRM);
      end;
    end if;
  end loop;
end;
/
