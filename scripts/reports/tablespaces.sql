/*
*/
@@reports.inc

column tablespace_name format a30 heading "Tablespace"
column contents format a10 heading "Type"
column force_logging format a15 heading "Force logging"
column retention format a15 heading "Retention"
column bigfile format a8 heading "BigFile?"

SELECT tablespace_name, contents, force_logging, retention, bigfile
FROM dba_tablespaces
ORDER BY decode(contents, 'UNDO', 1, 'TEMPORARY', 2, 0), tablespace_name
/

column files_count format 9990 heading "Files count"
column autoextensible format a15 heading "Autoextensible"

PROMPT
PROMPT =============================================================
PROMPT

SELECT tablespace_name, files_count, decode(autoextensible, 0, 'NO', 'YES') as autoextensible
FROM (SELECT f.tablespace_name, t.contents, count(f.file_id) as files_count, sum(f.bytes) as bytes, sum(decode(f.maxbytes, 0, 32 * power(2, 30), f.maxbytes)) as max_size, sum(decode(f.autoextensible, 'NO', 0, 1)) as autoextensible
      FROM dba_data_files f, dba_tablespaces t
      WHERE t.tablespace_name = f.tablespace_name
      GROUP BY f.tablespace_name, t.contents
      UNION ALL
      SELECT f.tablespace_name, t.contents, count(f.file_id) as files_count, sum(f.bytes) as bytes, sum(decode(f.maxbytes, 0, 32 * power(2, 30), f.maxbytes)) as max_size, sum(decode(f.autoextensible, 'NO', 0, 1)) as autoextensible
      FROM dba_temp_files f, dba_tablespaces t
      WHERE t.tablespace_name = f.tablespace_name
      GROUP BY f.tablespace_name, t.contents)
ORDER BY decode(contents, 'UNDO', 1, 'TEMPORARY', 2, 0), tablespace_name
/

