/*
*/
@@reports.inc

set feedback off

column inst_id format 9990 heading "#"
column instance_name format a10 heading "Instance"
column host_name format a20 heading "Host name"
column status format a14 heading "Instance status"
column archiver format a10 heading "Archiver"
column database_status format a10 heading "DB status"
column active_state format a10 heading "Active state"
column blocked format a8 heading "Blocked"
column log_switch_wait format a12 heading "Log switch"

SELECT inst_id, instance_name, host_name, database_status, status, active_state, archiver, log_switch_wait, blocked, SHUTDOWN_PENDING, PARALLEL
FROM gv$instance
ORDER BY inst_id
/

/*
 INSTANCE_NUMBER                                                                                                NUMBER
 VERSION                                                                                                        VARCHAR2(17)
 STARTUP_TIME                                                                                                   DATE
 PARALLEL                                                                                                       VARCHAR2(3)
 THREAD#                                                                                                        NUMBER
 LOGINS                                                                                                         VARCHAR2(10)
 SHUTDOWN_PENDING                                                                                               VARCHAR2(3)
 INSTANCE_ROLE                                                                                                  VARCHAR2(18)
*/

set feedback on
