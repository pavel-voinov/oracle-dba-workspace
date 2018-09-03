/*
*/
@@reports.inc

column owner format a25 heading "Owner"
column job_name format a30 heading "Job name"
column operation format a15 heading "Operation"
column job_mode format a15 heading "Job mode"
column state format a15 heading "Job status"
column degree format 9990 heading "Paralell degree"

SELECT owner_name as owner, job_name, operation, job_mode, state, degree
FROM dba_datapump_jobs
ORDER BY owner_name, job_name
/
