/*
To fix:
ORA-12012: error on auto execute of job <N>
ORA-01878: specified field not found in datetime or interval
*/

select j.log_user, last_date, next_date
  'exec DBMS_JOB.NEXT_DATE(' || job || ', to_date(''' || to_char(next_date + 6, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS''));'
from dba_jobs j
where NEXT_DATE < sysdate;

exec DBMS_JOB.NEXT_DATE(50, to_date('2014-04-05 02:08:27', 'YYYY-MM-DD HH24:MI:SS'));
exec DBMS_JOB.NEXT_DATE(273, to_date('2014-04-05 02:09:47', 'YYYY-MM-DD HH24:MI:SS'));
exec DBMS_JOB.NEXT_DATE(16, to_date('2014-04-05 02:17:26', 'YYYY-MM-DD HH24:MI:SS'));
exec DBMS_JOB.NEXT_DATE(248, to_date('2014-04-05 02:17:26', 'YYYY-MM-DD HH24:MI:SS'));
exec DBMS_JOB.NEXT_DATE(281, to_date('2014-04-05 02:17:31', 'YYYY-MM-DD HH24:MI:SS'));

/*
connect as log_user and execute dbms_job command
*/
