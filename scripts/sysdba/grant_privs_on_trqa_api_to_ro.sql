declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT owner, object_name
            FROM dba_objects
            WHERE owner = 'TRQA_API' AND object_type = 'PACKAGE')
  loop
    l_SQL := 'GRANT EXECUTE ON "' || t.owner || '"."' || t.object_name || '" TO "CORTELLIS_RO"';
    dbms_output.put_line(l_SQL || ';');
    execute immediate l_SQL;
  end loop;
end;
/
