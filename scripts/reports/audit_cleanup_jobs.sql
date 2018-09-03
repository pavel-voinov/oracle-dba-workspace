/*
*/
@@reports.inc

column job_name format a30 heading "Job name"
column job_status format a15 heading "Job status"
column audit_trail format a30 heading "Audit trail type"
column job_frequency format a50 heading "Job frequency"


SELECT job_name, job_status, audit_trail, job_frequency
FROM dba_audit_mgmt_cleanup_jobs
ORDER BY job_name
/

