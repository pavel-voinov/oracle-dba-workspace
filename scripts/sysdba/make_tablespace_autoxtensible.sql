/*

Make datafiles for tablespace as autoextensible and with unlimited maxsize.
*/
define ts=&1

begin
  for f in (SELECT file_id
            FROM dba_data_files
            WHERE tablespace_name = upper('&ts')
              AND autoextensible = 'NO')
  loop
    execute immediate 'ALTER DATABASE DATAFILE ' || f.file_id || ' AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
  end loop;
  for f in (SELECT file_id
            FROM dba_temp_files
            WHERE tablespace_name = upper('&ts')
              AND autoextensible = 'NO')
  loop
    execute immediate 'ALTER DATABASE TEMPFILE ' || f.file_id || ' AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
  end loop;
end;
/
