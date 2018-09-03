/*
*/
@@reports.inc

column thread# format 990 heading "Thread"
column size_mb format 999999990 heading "Size, Mb"
column completion_date heading "Date"

break on report
break on completion_date
compute sum label "Total" of size_mb on report
compute sum label "Total" of size_mb on completion_date
alter session set nls_date_format='DD.MM.YYYY'
/
SELECT thread#, trunc(completion_time) as completion_date,
  ceil(sum(blocks * block_size) / power(2, 20)) as size_mb
FROM v$archived_log
GROUP BY thread#, trunc(completion_time)
ORDER BY 2 desc, 1
/
alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS'
/
