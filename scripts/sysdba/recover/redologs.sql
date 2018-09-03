SELECT *
FROM v$sysstat
WHERE name like '%redo%'
order by value desc, name
/
SELECT A.*,
 Round(A.Count#*B.AVG#/1024/1024) Daily_Avg_Mb
 FROM
 (
 SELECT
 To_Char(First_Time,'YYYY-MM-DD') DAY,
 Count(1) Count#,
 Min(RECID) Min#,
 Max(RECID) Max#
 FROM
 v$log_history
 GROUP
 BY To_Char(First_Time,'YYYY-MM-DD')
 ORDER
 BY 1 DESC
 ) A,
 (
 SELECT
 Avg(BYTES) AVG#,
 Count(1) Count#,
 Max(BYTES) Max_Bytes,
 Min(BYTES) Min_Bytes
 FROM
 v$log
 ) B;
 
 
 SELECT to_char(begin_interval_time,'YY-MM-DD HH24') snap_time,
 dhso.object_name,
 sum(db_block_changes_delta) BLOCK_CHANGED
 FROM dba_hist_seg_stat dhss,
 dba_hist_seg_stat_obj dhso,
 dba_hist_snapshot dhs
 WHERE dhs.snap_id = dhss.snap_id
 AND dhs.instance_number = dhss.instance_number
 AND dhss.obj# = dhso.obj#
 AND dhss.dataobj# = dhso.dataobj#
 AND begin_interval_time BETWEEN to_date('12-02-12 08:00','YY-MM-DD HH24:MI')
 AND to_date('12-02-13 08:00','YY-MM-DD HH24:MI')
 GROUP BY to_char(begin_interval_time,'YY-MM-DD HH24'),
 dhso.object_name
 HAVING sum(db_block_changes_delta) > 0
ORDER BY sum(db_block_changes_delta) desc ;


select s.inst_id, s.sid, n.name, s.value, sn.username, sn.program, sn.type, sn.module
from gv$sesstat s 
  join v$statname n on n.statistic# = s.statistic#
  join gv$session sn on sn.sid = s.sid
where name like '%redo entries%' and s.inst_id = sn.inst_id
order by value desc;

select * from gv$session where inst_id = 3 and sid in (836);
select 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || serial# || ',@' || inst_id || ''';' from gv$session where inst_id = 3 and program like 'oracle@c111wtc (P0%)' and status = 'ACTIVE'
order by program;
select * from gv$session where inst_id = 2 and sid = 2;

select * from gv$process where inst_id = 3 and addr = '00000013D1039EC8';

select min(first_change#), max(next_change#) from v$log where thread# = 1 and status = 'ACTIVE';
select * from v$log where thread# = 1 and status = 'ACTIVE';
2025121283247

select * from gv$transaction where start_scn >= 2025121283247;

select * from gv$session where saddr = '00000013B1255578';
select * from gv$process where inst_id = 1 and addr = '00000013D1030898';

select * from v$log_history;

SELECT s.inst_id, s.sid, s.username, s.program, t.value "redo blocks written"
  FROM gv$session s, gv$sesstat t
 WHERE s.sid = t.sid
   AND s.inst_id = t.inst_id
   AND t.value != 0
   AND t.statistic# = (select statistic# from v$statname
                        where name = 'redo size')
ORDER BY 5 desc
/

select * from gv$session where sid = 1027;
select * from V$RECOVERY_LOG;

select * from gv$logmnr_logfile;

exec dbms_logmnr.start_logmnr(startscn => 621047,  endscn => 625695, options => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG + DBMS_LOGMNR.CONTINUOUS_MINE);
select * from v$logmnr_contents;
exec dbms_logmnr.end_logmnr;


select * from v$system_event order by 4 desc;


select event, count(*) from v$session_wait group by event;


select inst_id, usn, slt, seq, done, ela_mins, est_mins, est_mins - ela_mins as left_mins
from (
select inst_id, usn, slt, seq, round(undoblocksdone/undoblockstotal * 100, 1) as done,
  round(cputime / 60) as ela_mins,
  round(cputime / undoblocksdone * undoblockstotal / 60) est_mins
from gv$fast_start_transactions)
order by 1;

--86740	2191495		10376
--89263	2184612		9786
--2384	2071919		1937
