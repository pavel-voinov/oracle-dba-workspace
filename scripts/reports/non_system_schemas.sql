/*
*/
@@reports.inc
@system_users_filter.sql

column owner format a30 heading "Schema name"

SELECT owner, ceil(sum(bytes) / power(2, 20)) as size_mb
FROM dba_segments
WHERE not regexp_like(owner, :v_sys_users_regexp)
GROUP BY owner
ORDER BY 1
/
