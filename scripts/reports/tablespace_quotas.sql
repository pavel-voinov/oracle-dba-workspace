/*
*/
@@reports.inc

column tablespace_name format a30 heading "Tablespace"
column username format a30 heading "Username"
column max_size_mb format a15 heading "Max size, MB"
column dropped format a10 heading "Dropped"

SELECT username, tablespace_name, decode(max_bytes, -1, 'UNLIMITED', round(max_bytes / power(2, 20)) || 'M') as max_size_mb, dropped
FROM dba_ts_quotas
WHERE not regexp_like(username, '^U[CX0-9]{7}$')
ORDER BY username, tablespace_name
/
