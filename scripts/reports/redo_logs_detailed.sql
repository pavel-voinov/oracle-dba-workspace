/*
*/
@@reports.inc

column group# format 990 heading "Group#"
column thread# format 990 heading "Thread#"
column sequence# format 999999990 heading "Sequence#"
column first_change# format 999999999999990 heading "First SCN"
column next_change# format 999999999999990 heading "Next SCN"
column first_time heading "First Time"
column next_time heading "Next Time"
column size_mb format 999,999,990 heading "Size, Mb"
column members format 90 heading "Members"
column status format a15 heading "Status"
column archived heading "Archived"

break on report
break on completion_date
compute sum label "Total" of size_mb on report
compute sum label "Total" of size_mb on thread#
alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS'
/
SELECT thread#, group#, sequence#, members, ceil(bytes / power(2, 20)) as size_mb, archived, status, first_change#, next_change#, first_time, next_time
FROM v$log
ORDER BY thread#, group#
/

clear breaks
clear computes
