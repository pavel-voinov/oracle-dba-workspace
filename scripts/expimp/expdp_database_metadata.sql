/*
*/
set serveroutput on size unlimited buffer 100000 verify off timing off scan on

define p_dir=&1
define p_mask=&2
define p_use_scn=Y

set termout off
column p_mask new_value p_mask
column p_dump new_value p_dump
column p_log new_value p_log
column p_job new_value p_job
SELECT regexp_replace('&p_mask', '^(.*?)(|_%U)(|.dmp)$', '\1', 1, 0, 'i') as p_mask FROM dual
/
SELECT '&p_mask' || '.dmp' as p_dump, '&p_mask' || '.log' as p_log, upper(substr('EXP_&p_mask', 1, 30)) as p_job
FROM dual
/
set termout on

@expimp/p/expdp_database_metadata.sql

undefine p_dir
undefine p_dump_mask
undefine p_dump
undefine p_log
undefine p_job
