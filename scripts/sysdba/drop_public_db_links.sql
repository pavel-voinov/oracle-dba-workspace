/*
*/
begin
  commit;
  for l in (SELECT db_link FROM all_db_links WHERE owner = 'PUBLIC')
  loop
    execute immediate 'DROP PUBLIC DATABASE LINK "' || l.db_link || '"';
  end loop;
end;
/
