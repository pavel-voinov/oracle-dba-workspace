/*
Show tablespaces with usage % > 90
*/
@@reports.inc

column tablespace_name format a30 heading "Tablespace"
column files_count format 9990 heading "Files count"
column size_mb format 999,999,999,990 heading "Size, MB"
column max_size_mb format 999,999,999,990 heading "Max size, MB"
column min_files_count format 9990 heading "Min. files count"
column autoextensible format a13 heading "Autoextensible"
column used_percent format 990.0 heading "Used, %"

SELECT a.tablespace_name, a.files_count, ceil(a.bytes / power(2, 20) / 32768) as min_files_count, decode(a.autoextensible, 0, 'NO', 'YES') as autoextensible, ceil(a.bytes / power(2, 20)) as size_mb, ceil(a.max_size / power(2, 20)) as max_size_mb, m.used_percent
FROM (SELECT f.tablespace_name, t.contents, count(f.file_id) as files_count, sum(f.bytes) as bytes, sum(decode(f.maxbytes, 0, 32 * power(2, 30), f.maxbytes)) as max_size, sum(decode(f.autoextensible, 'NO', 0, 1)) as autoextensible
      FROM dba_data_files f, dba_tablespaces t
      WHERE t.tablespace_name = f.tablespace_name
      GROUP BY f.tablespace_name, t.contents
      UNION ALL
      SELECT f.tablespace_name, t.contents, count(f.file_id) as files_count, sum(f.bytes) as bytes, sum(decode(f.maxbytes, 0, 32 * power(2, 30), f.maxbytes)) as max_size, sum(decode(f.autoextensible, 'NO', 0, 1)) as autoextensible
      FROM dba_temp_files f, dba_tablespaces t
      WHERE t.tablespace_name = f.tablespace_name
      GROUP BY f.tablespace_name, t.contents) a,
     dba_tablespace_usage_metrics m
WHERE m.tablespace_name = a.tablespace_name(+) and m.used_percent > 90
ORDER BY decode(a.contents, 'UNDO', 1, 'TEMPORARY', 2, 0), m.used_percent desc, a.tablespace_name
/
