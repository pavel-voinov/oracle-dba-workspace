/*
*/
@@reports.inc

column tablespace_name format a30 heading "Tablespace"
column file_id format 990 heading "ID"
column file_name format a70 heading "File name"
column size_mb format 9,999,990 heading "Size, MB"
column max_size_mb format a14 heading "Max size, MB"
column increment_by_mb format a12 heading "Incr. by, MB"
column autoextensible format a8 heading "Autoext."
column bigfile format a7 heading "BigFile"
column status format a12 heading "Status"

break on report
break on tablespace_name
compute sum label "Total size" of size_mb on report
compute sum label "Total size" of size_mb on tablespace_name

SELECT f.tablespace_name, f.file_id, f.file_name,
  ceil(f.bytes / power(2, 20)) as size_mb,
  f.autoextensible,
  t.bigfile,
  decode(f.autoextensible, 'NO', '', to_char(ceil(f.increment_by * to_number(p.value) / power(2, 20)), '999,990')) as increment_by_mb,
  decode(t.bigfile, 'YES', '', lpad(decode(f.autoextensible, 'NO', '', decode(f.maxbytes, 34359721984, 'UNLIMITED', to_char(ceil(f.maxbytes / power(2, 20)), '99,999,990'))), 14)) as max_size_mb,
  f.status
FROM dba_data_files f, v$parameter p, dba_tablespaces t
WHERE p.name = 'db_block_size' and t.tablespace_name = f.tablespace_name
ORDER BY f.tablespace_name, f.file_name
/
