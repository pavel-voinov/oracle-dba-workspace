/*
*/
set linesize 250 pagesize 9999 heading off  echo off feedback off trimspool on

column sql_text format a230 heading "SQL"

SELECT 'ALTER DATABASE DATAFILE ' || file_id || ' RESIZE ' || case when new_size_mb > 32768 then 32768 else new_size_mb end || 'M /* ' || tablespace_name || ' (' || size_mb || 'M) */;' as sql_text
FROM (
SELECT file_id, tablespace_name, file_name,
  ceil(bytes / power(2, 20)) as size_mb,
  ceil(bytes / power(2, 20) / 100) * 100 as new_size_mb,
  autoextensible,
  decode(autoextensible, 'NO', '', to_char(ceil(increment_by * to_number(p.value) / power(2, 20)), '999,990')) as increment_by_mb,
  lpad(decode(autoextensible, 'NO', '', decode(maxbytes, 34359721984, 'UNLIMITED', to_char(ceil(maxbytes / power(2, 20)), '99,999,990'))), 14) as max_size_mb,
  status
FROM dba_data_files, v$parameter p
WHERE p.name = 'db_block_size'
ORDER BY tablespace_name, file_name
)
WHERE new_size_mb > size_mb and new_size_mb < 32768
/
