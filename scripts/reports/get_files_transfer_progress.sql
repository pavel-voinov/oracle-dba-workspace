/*
*/
@@reports.inc

column inst_id format 9990 heading "Instance"
column username format a20 heading "Username"
column file_name format a40 heading "File name"
column time_remaining format 9999999990 heading "Time remaining|sec"
column time_elapsed   format 9999999990 heading "Time elapsed|sec"
column pct_done format 990 heading "Done,%"
column start_time heading "Started"

SELECT inst_id, username, target_desc as file_name,
  round(sofar / decode(totalwork, 0, sofar, totalwork) * 100) as pct_done, start_time,
  time_remaining, elapsed_seconds as time_elapsed
FROM gv$session_longops
WHERE opname like 'DBMS_FILE_TRANSFER%'
ORDER BY start_time
/
