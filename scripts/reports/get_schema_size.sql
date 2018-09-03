/*
*/
@@reports.inc
@system_users_filter.sql

define schema=&1

column size_mb format 999,999,999,990 heading 'Size, Mb'
column tablespace_name format a30 heading 'Tablespace'
break on report
compute sum label "Total" of size_mb on report

SELECT tablespace_name, round(sum(bytes) / power(2, 20)) as size_mb
FROM dba_segments
WHERE regexp_like(owner, '^&schema$', 'i')
GROUP BY tablespace_name
ORDER BY 1, 2
/

TTITLE OFF
