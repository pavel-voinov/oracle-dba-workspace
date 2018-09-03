/*
*/
@@reports.inc

column schema_user format a30 heading "Schema"
column tablespace_name format a30 heading "Tablespace"
column size_mb format 999,999,990 heading "Size, Mb"
column min_files_count format 9990 heading "Min files count"

SELECT owner as schema_user, tablespace_name, size_mb, ceil(size_mb / 32768) as min_files_count
FROM (SELECT owner, tablespace_name, ceil(sum(bytes) / 1024 / 1024) as size_mb
      FROM dba_segments
      GROUP BY owner, tablespace_name)
ORDER BY schema_user, tablespace_name
/
