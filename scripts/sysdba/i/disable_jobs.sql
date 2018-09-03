/*
*/
set serveroutput on size unlimited echo off

ACCEPT owner PROMPT "Owner: "

PROMPT
PROMPT Disabled jobs (before)
column schema_user format a30 heading "Owner"
column job format 999990 heading "Job ID"
column what format a150 heading "Action" word_wrapped  
SELECT schema_user, job, broken, next_date, what
FROM dba_jobs
WHERE regexp_like(schema_user, '^&owner.$', 'i')
  AND (next_date is null OR broken = 'Y')
/
begin
  dbms_output.enable(null);
  for x in (SELECT job, next_date
            FROM dba_jobs t
            WHERE regexp_like(schema_user, '^&owner.$', 'i')
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
PROMPT
PROMPT Disabled jobs (after)
column schema_user format a30 heading "Owner"
column job format 999990 heading "Job ID"
column what format a150 heading "Action" word_wrapped  
SELECT schema_user, job, broken, next_date, what
FROM dba_jobs
WHERE regexp_like(schema_user, '^&owner.$', 'i')
  AND (next_date is null OR broken = 'Y')
/
