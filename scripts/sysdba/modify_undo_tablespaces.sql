/*

UNDO tablespaces modifies to be autoextensible and with unlimited maxsize.
For Editorial databases it should be guaranteed as well
*/
begin
  for f in (SELECT f.file_id
            FROM dba_data_files f, dba_tablespaces t
            WHERE f.tablespace_name = t.tablespace_name
              AND t.contents = 'UNDO'
              AND f.autoextensible = 'NO')
  loop
    execute immediate 'ALTER DATABASE DATAFILE ' || f.file_id || ' AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
  end loop;
  for f in (SELECT tablespace_name
            FROM dba_tablespaces
            WHERE contents = 'UNDO'
              AND retention = 'NOGUARANTEE')
  loop
    execute immediate 'ALTER TABLESPACE "' || f.tablespace_name || '" RETENTION GUARANTEE';
  end loop;
end;
/
