declare
  l_ddl     varchar2(32767);
  l_wrapped varchar2(32767);
begin
  for f in (select table_name from user_tables where table_name like '%_BAK') loop
    begin
      execute immediate 'drop table ' || f.table_name;
    exception when others
      then dbms_output.put_line(f.table_name || ':' || SQLERRM);
    end;
  end loop;

  for f in (select replace(decode(object_type, 'PACKAGE', 'PACKAGE_SPEC', 'TYPE', 'TYPE_SPEC', object_type), ' ', '_') as object_type,
              object_name
            from user_objects u
            where object_type IN ('PACKAGE', 'PACKAGE BODY', 'TYPE', 'TYPE BODY', 'PROCEDURE', 'FUNCTION') and
              object_name not like 'SYS_PLSQL_%') loop
    begin
      l_ddl := dbms_metadata.get_ddl(f.object_type, f.object_name);
      l_wrapped := dbms_ddl.wrap(l_ddl);
      execute immediate l_wrapped;
    exception when others
      then dbms_output.put_line(f.object_type || ':' || f.object_name || ':' || SQLERRM);
    end;
  end loop;
end;
/
