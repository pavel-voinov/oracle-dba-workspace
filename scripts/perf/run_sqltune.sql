/*

Based on sqltrpt.sql
*/
set serveroutput on size unlimited timing on long 65536 longchunksize 65536 linesize 250 pagesize 9999 verify off

define sqlid=&1
variable task_name varchar2(128);
variable err       number;

set termout off
column sqlid new_value sqlid
SELECT lower('&&sqlid') as sqlid FROM dual;
set termout on

spool /tmp/sqlt_&&sqlid..log

-- By default, no error
execute :err := 0;

declare
  cnt number;
  bid number;
  eid number;
begin
  -- If it's not in V$SQL we will have to query the workload repository
  SELECT count(*) INTO cnt FROM v$sqlstats WHERE sql_id = '&&sqlid';

  if cnt > 0 then
    :task_name := dbms_sqltune.create_tuning_task(sql_id => '&&sqlid', scope => 'COMPREHENSIVE', time_limit => 60, description => 'Task to tune SQL "&sqlid"');
  else
    select min(snap_id) into bid
    from dba_hist_sqlstat
    where sql_id = '&&sqlid';

    select max(snap_id) into eid
    from dba_hist_sqlstat
    where sql_id = '&&sqlid';

    :task_name := dbms_sqltune.create_tuning_task(begin_snap => bid, end_snap => eid, sql_id => '&&sqlid');
  end if;

  dbms_sqltune.execute_tuning_task(:task_name);

exception
  when others then
    :err := 1;

    if (SQLCODE = -13780) then
      dbms_output.put_line ('ERROR: statement is not in the cursor cache or the workload repository.');
      dbms_output.put_line('Execute the statement and try again');
    else
      raise;
    end if;   
end;
/

column task_name format a30
PROMPT Task name:
set heading off
PRINT :task_name
PROMPT SQL Tune Advisor results
select dbms_sqltune.report_tuning_task(:task_name) from dual where :err <> 1;
select '   ' from dual where :err = 1;
set heading on

spool off

PROMPT check "/tmp/sqlt_&&sqlid..log" for report

undefine sqlid
