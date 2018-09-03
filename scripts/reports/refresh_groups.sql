/*
*/
@@reports.inc

column rowner format a30 heading "Owner"
column rname format a30 heading "Name"
column refresh_after_errors format a10 heading "Refresh|after|errors" justify center
column parallelism format 9990 heading "Parallelism"

SELECT rowner, rname, refresh_after_errors, parallelism
FROM dba_refresh
ORDER BY 1, 2
/
