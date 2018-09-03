/*
*/
set serveroutput on size 1000000 buffer 100000 verify off timing off scan on

define p_schema=&1
define p_dir=&2
define p_dump_mask=&3

set termout off
column p_dump new_value p_dump
column p_log new_value p_log
column p_job new_value p_job
SELECT '&p_dump_mask._%U.dmp' as p_dump, '&p_dump_mask..log' as p_log, 'EXP_&p_dump_mask.' as p_job
FROM dual;
set termout off

define p_parallel=2
define p_tables=''
define p_reusefile=Y
define p_use_SCN=Y
define p_content=ALL
define p_cluster_ok=1
define p_run_as_job=Y

@expimp/p/expdp.sql
