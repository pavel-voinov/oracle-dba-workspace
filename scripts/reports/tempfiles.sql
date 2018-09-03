/*
*/
@@reports.inc

column file_id format 990 heading "ID"
column file_name format a75 heading "File name"
column tablespace_name format a20 heading "Tablespace name"
column size_mb format 999,999,990 heading "Size, MB"
column increment_by_mb format 999,999,990 heading "Increment by, MB"
column max_size_mb format 999,999,990 heading "Max size, MB"
column autoextensible format a10 heading "Autoextensible"
column status format a10 heading "Status"

SELECT file_id, tablespace_name, file_name, ceil(bytes / power(2, 20)) as size_mb,
  autoextensible, ceil(increment_by * to_number(p.value) / power(2, 20)) as increment_by_mb, ceil(maxbytes / power(2, 20)) as max_size_mb, status
FROM dba_temp_files, v$parameter p
WHERE p.name = 'db_block_size'
ORDER BY tablespace_name, file_name
/
