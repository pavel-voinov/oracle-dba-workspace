set echo off
set linesize 5000
set trimspool on
set serveroutput on
set termout off
set timing off

column owner format a11
column unit_name format a20
column text format a50 word_wrapped
column runid format 9999
column secs  format 9999.99
column hsecs format 9999.99
column grand_total  format 9999.99
column run_comment format a18 word_wrapped
column line# format 99999
column pct format 99999.9
column unit_owner format a11

spool profsum.out

/* Clean out rollup results, and recreate */
update plsql_profiler_units set total_time = 0;

execute prof_report_utilities.rollup_all_runs;

prompt =
prompt =
prompt ====================
prompt Total time
select grand_total/1000000000 as grand_total
  from plsql_profiler_grand_total;

prompt =
prompt =
prompt ====================
prompt Total time spent on each run
select runid,
       substr(run_comment,1, 30) as run_comment,
       run_total_time/1000000000 as secs
  from (select a.runid, sum(a.total_time)  run_total_time, b.run_comment
          from plsql_profiler_units a, plsql_profiler_runs b
         where a.runid = b.runid group by a.runid, b.run_comment )
 where run_total_time > 0
 order by runid asc;


prompt =
prompt =
prompt ====================
prompt Percentage of time in each module, for each run separately

select p1.runid,
       substr(p2.run_comment, 1, 20) as run_comment,
       p1.unit_owner,
       decode(p1.unit_name, '', '<anonymous>',
                    substr(p1.unit_name,1, 20)) as unit_name,
       p1.total_time/1000000000 as secs,
       TO_CHAR(100*p1.total_time/p2.run_total_time, '999.9') as pct
  from plsql_profiler_units p1,
       (select a.runid, sum(a.total_time)  run_total_time, b.run_comment
          from plsql_profiler_units a, plsql_profiler_runs b
         where a.runid = b.runid group by a.runid, b.run_comment ) p2
 where p1.runid=p2.runid
   and p1.total_time > 0
   and p2.run_total_time > 0
   and  (p1.total_time/p2.run_total_time)  >= .01
 order by p1.runid asc, p1.total_time desc;

column secs form 9.99
prompt =
prompt =
prompt ====================
prompt Percentage of time in each module, summarized across runs
select p1.unit_owner,
       decode(p1.unit_name, '', '<anonymous>', substr(p1.unit_name,1, 25)) as unit_name,
       p1.total_time/1000000000 as secs,
       TO_CHAR(100*p1.total_time/p2.grand_total, '99999.99') as percentage
  from plsql_profiler_units_cross_run p1,
       plsql_profiler_grand_total p2
 order by p1.total_time DESC;


prompt =
prompt =
prompt ====================
prompt Lines taking more than 1% of the total time, each run separate
select p1.runid as runid,
       p1.total_time/10000000 as Hsecs,
        p1.total_time/p4.grand_total*100 as pct,
       substr(p2.unit_owner, 1, 20) as owner,
       decode(p2.unit_name, '', '<anonymous>', substr(p2.unit_name,1, 20)) as unit_name,
       p1.line#,
       ( select p3.text
           from all_source p3
          where p3.owner = p2.unit_owner and
                p3.line = p1.line# and
                p3.name=p2.unit_name and
                p3.type not in ( 'PACKAGE', 'TYPE' )) text
  from plsql_profiler_data p1,
       plsql_profiler_units p2,
       plsql_profiler_grand_total p4
 where (p1.total_time >= p4.grand_total/100)
   AND p1.runID = p2.runid
   and p2.unit_number=p1.unit_number
 order by p1.total_time desc;

prompt =
prompt =
prompt ====================
prompt Most popular lines (more than 1%), summarize across all runs
select p1.total_time/10000000 as hsecs,
        p1.total_time/p4.grand_total*100 as pct,
       substr(p1.unit_owner, 1, 20) as unit_owner,
       decode(p1.unit_name, '', '<anonymous>',
                 substr(p1.unit_name,1, 20)) as unit_name,
       p1.line#,
       ( select p3.text from all_source p3
          where (p3.line = p1.line#) and
                (p3.owner = p1.unit_owner) AND
                (p3.name = p1.unit_name) and
                (p3.type not in ( 'PACKAGE', 'TYPE' ) ) ) text
  from  plsql_profiler_lines_cross_run p1,
        plsql_profiler_grand_total p4
 where (p1.total_time >= p4.grand_total/100)
 order by p1.total_time desc;

execute prof_report_utilities.rollup_all_runs;

prompt =
prompt =
prompt ====================
prompt  Number of lines actually executed in different units (by unit_name)

select p1.unit_owner,
       p1.unit_name,
       count( decode( p1.total_occur, 0, null, 0))  as lines_executed ,
       count(p1.line#) as lines_present,
       count( decode( p1.total_occur, 0, null, 0))/count(p1.line#) *100
                                       as pct
  from plsql_profiler_lines_cross_run p1
 where (p1.unit_type in ( 'PACKAGE BODY', 'TYPE BODY',
                          'PROCEDURE', 'FUNCTION' )  )
 group by p1.unit_owner, p1.unit_name;


prompt =
prompt =
prompt ====================
prompt  Number of lines actually executed for all units
select count(p1.line#) as lines_executed
  from plsql_profiler_lines_cross_run p1
 where (p1.unit_type in ( 'PACKAGE BODY', 'TYPE BODY',
                          'PROCEDURE', 'FUNCTION' )  )
    AND p1.total_occur > 0;


prompt =
prompt =
prompt ====================
prompt  Total number of lines in all units
select count(p1.line#) as lines_present
  from plsql_profiler_lines_cross_run p1
 where (p1.unit_type in ( 'PACKAGE BODY', 'TYPE BODY',
                          'PROCEDURE', 'FUNCTION' )  );

spool off
set termout on
edit profsum.out
set linesize 131

