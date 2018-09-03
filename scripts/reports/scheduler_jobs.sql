/*
*/
@@reports.inc

column owner format a30 heading "Owner"
column job_name format a30 heading "Job Name"
column job_subname format a30 heading "Job Subname"
column job_style format a11 heading "Job Style"
column job_type format a16 heading "Job Type"
column job_creator format a30 heading "Job Creator"
column program_name format a50 heading "Program name" newline
column schedule_name format a50 heading "Schedule name"
column schedule_type format a12 heading "Schedule type"
column event_rule format a60 heading "Event rule"
column enabled format a8 heading "Enabled"
column auto_drop format a8 heading "AutoDrop" newline
column restartable format a12 heading "Restartable"
column number_of_arguments format 9990 heading "Arguments"
column credential_name format a30 heading "Credential name"
column comments format a150 heading "Comments" newline word_wrapped

SELECT owner, job_name, job_subname, job_style, job_type, job_creator, enabled,
  decode(program_name, null, '', program_owner || '.' || program_name) as program_name,
  decode(schedule_name, null, '', schedule_owner || '.' || schedule_name) as schedule_name, schedule_type,
  auto_drop, restartable, event_rule,
  decode(credential_name, null, '', credential_owner || '.' || credential_name) as credential_name,
  comments 
FROM dba_scheduler_jobs
ORDER BY 1, 2
/
