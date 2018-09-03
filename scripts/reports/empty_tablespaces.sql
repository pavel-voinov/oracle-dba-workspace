/*
*/
@@reports.inc

column tablespace_name format a30 heading "Tablespace"
column files_count format 9990 heading "Files count"
column size_mb format 999,999,990 heading "Size, Mb"


SELECT f.tablespace_name, count(f.file_id) as files_count, ceil(sum(f.bytes) / 1024 / 1024) as size_mb
FROM dba_data_files f, dba_tablespaces t
WHERE t.tablespace_name = f.tablespace_name
  AND decode(t.contents, 'UNDO', 1, 0) = 0
  AND not exists (SELECT null FROM dba_segments s WHERE s.tablespace_name = f.tablespace_name)
GROUP BY f.tablespace_name
ORDER BY tablespace_name
/

