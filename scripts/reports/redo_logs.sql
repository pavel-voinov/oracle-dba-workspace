/*
*/
@@reports.inc

column group# format 990 heading "Group#"
column size_mb format 999,999,990 heading "Size, Mb"
column members format 90 heading "Members"

break on report
break on completion_date
compute sum label "Total" of size_mb on report
compute sum label "Total" of size_mb on thread#

SELECT thread#, group#, members, ceil(bytes / power(2, 20)) as size_mb
FROM v$log
ORDER BY thread#, group#, members
/

clear breaks
clear computes
