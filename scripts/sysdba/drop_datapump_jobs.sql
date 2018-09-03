/*
*/
begin
  for t in (SELECT '"' || owner_name || '"."' || job_name || '"' as table_name
            FROM dba_datapump_jobs
            WHERE state = 'NOT RUNNING')
  loop
    execute immediate 'DROP TABLE ' || t.table_name;
  end loop;
end;
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT '"' || owner || '"."' || table_name || '"' as table_name
            FROM (SELECT owner, table_name
                  FROM dba_tables
                  WHERE regexp_like(table_name, '^SYS_(EXPORT|IMPORT)_(SCHEMA|TABLE|DATABASE)_[0-9]{2}$')
                  MINUS
                  SELECT owner_name, job_name
                  FROM dba_datapump_jobs 
                  WHERE state <> 'NOT RUNNING')
            ORDER BY 1)
  loop
    l_SQL := 'DROP TABLE ' || t.table_name;
    dbms_output.put_line(l_SQL || ';');
    execute immediate l_SQL;
  end loop;
end;
/
