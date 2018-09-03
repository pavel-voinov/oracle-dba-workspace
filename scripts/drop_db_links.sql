/*
*/
SELECT * FROM user_db_links
/
begin
  commit;
  for l in (SELECT db_link FROM user_db_links)
  loop
    execute immediate 'DROP DATABASE LINK "' || l.db_link || '"';
  end loop;
end;
/
