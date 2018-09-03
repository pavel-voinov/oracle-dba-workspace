set serveroutput on size unlimited buffer 100000 verify off timing on scan on

column p_owner new_value p_owner
set term off
SELECT user as p_owner FROM dual;
set term on

ACCEPT p_owner DEFAULT '&p_owner' PROMPT "Enter job owner [&p_owner]: "

column job_name format a30 heading "Job name"
column state format a30 heading "Job status"

SELECT job_name, state
FROM dba_datapump_jobs
WHERE owner_name = upper('&p_owner')
ORDER BY 1
/

ACCEPT p_job PROMPT "Enter name for export job: "

set term off
column p_owner new_value p_owner
SELECT nvl(upper(trim(p_owner)), user) as p_owner FROM dual;
set term on

PROMPT You have selected these parameters:
PROMPT   Job owner: &p_owner
PROMPT    Job name: &p_job

pause Press any key to kill export job and Ctrl-C to cancel further operations

declare
  l_handle integer;
begin
  l_handle := dbms_datapump.attach(job_owner => '&p_owner', job_name => '&p_job');
  dbms_datapump.stop_job(handle => l_handle, immediate => 1, keep_master => 0); 
end;
/
