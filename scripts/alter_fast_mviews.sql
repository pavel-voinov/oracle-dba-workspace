set serveroutput on size unlimited
define p_owner=&1

begin
  dbms_output.enable(null);
  for m in (SELECT owner, mview_name FROM dba_mviews WHERE owner = upper('&p_owner') AND refresh_method = 'FAST')
  loop
    dbms_output.put('"' || m.owner || '"."' || m.mview_name || '"... ');
    begin
      execute immediate 'ALTER MATERIALIZED VIEW "' || m.owner || '"."' || m.mview_name || '" REFRESH FORCE';
      dbms_output.put_line('OK');
    exception when others then
      dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
