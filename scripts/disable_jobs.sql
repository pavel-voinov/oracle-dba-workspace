/*
*/
set serveroutput on size unlimited echo off

set termout off
column p_owner new_value p_owner
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as p_owner FROM dual;
set termout on

PROMPT
PROMPT Disabled jobs (before)
column schema_user format a30 heading "Owner"
column job format 999990 heading "Job ID"
column what format a150 heading "Action" word_wrapped  
SELECT schema_user, job, broken, next_date, what
FROM all_jobs
WHERE regexp_like(schema_user, '^&p_owner.$', 'i')
  AND (next_date is null OR broken = 'Y')
/
SELECT owner, job_name
FROM all_scheduler_jobs
WHERE regexp_like(owner, '^&p_owner.$', 'i')
  AND enabled = 'FALSE'
/
begin
  dbms_output.enable(null);
  for x in (SELECT job, next_date
            FROM all_jobs t
            WHERE regexp_like(schema_user, '^&p_owner.$', 'i')
              AND next_date is not null
              AND broken = 'N')
  loop
    begin
      dbms_output.put(x.job || ': ');
      dbms_job.broken(job => x.job, broken => true);
      dbms_output.put_line('OK');
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
begin
  dbms_output.enable(null);
  for x in (SELECT '"' || owner || '"."' || job_name || '"' as job_name
            FROM all_scheduler_jobs
            WHERE regexp_like(owner, '^&p_owner.$', 'i')
              AND enabled = 'TRUE')
  loop
    begin
      dbms_output.put(x.job_name || ': ');
      dbms_scheduler.disable(name=> x.job_name, force => true);
      dbms_output.put_line('OK');
    exception
      when others then
        dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
PROMPT
PROMPT Disabled jobs (after)
column schema_user format a30 heading "Owner"
column job format 999990 heading "Job ID"
column what format a150 heading "Action" word_wrapped  
SELECT schema_user, job, broken, next_date, what
FROM all_jobs
WHERE regexp_like(schema_user, '^&p_owner.$', 'i')
  AND (next_date is null OR broken = 'Y')
/
SELECT owner, job_name
FROM all_scheduler_jobs
WHERE regexp_like(owner, '^&p_owner.$', 'i')
  AND enabled = 'FALSE'
/
