/*
*/
declare
  executions MGMT_JOB_GUID_ARRAY;
begin
  SELECT EXECUTION_ID BULK COLLECT INTO executions
  FROM MGMT$JOB_EXECUTION_HISTORY
  WHERE status in ('Succeeded');

  mgmt_jobs.delete_job_executions(p_execution_ids => executions, p_commit => 1);
end;
/