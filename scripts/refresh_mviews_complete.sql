/*
*/
set serveroutput on size unlimited echo on timing on

define p_parallelism=16

@@compile_mviews
declare
  l_failed boolean;
  l_paralellism number := to_number('&p_parallelism');

  table_does_not_exist exception;
  pragma exception_init(table_does_not_exist, -942);
begin
  dbms_output.enable(null);
  for t in (SELECT '"' || owner || '"."' || mview_name || '"' as mview_name, refresh_method
            FROM all_mviews
            WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
            ORDER BY mview_name)
  loop
    dbms_application_info.set_client_info(t.mview_name);
    dbms_output.put(t.mview_name || ': ');
    begin
      dbms_mview.refresh(list => t.mview_name, method => 'C', parallelism => l_parallelism);
      dbms_output.put_line('ok');
    exception
      when table_does_not_exist then
        dbms_output.put_line('NEEDS TO BE RECREATED. ' || SQLERRM);
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
