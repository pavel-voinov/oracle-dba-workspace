/*

This script backups application contexts
*/

set serveroutput on size 1000000 linesize 1024 pagesize 9999 trimspool on newpage none

column sql_text format a4000 wrapped

select dbms_metadata.get_ddl('CONTEXT', namespace) || chr(10) || '/' as sql_text
from dba_context
order by namespace
/

--select dbms_metadata.get_ddl('RLS_CONTEXT', 'ORASSO_SSOC_CTX') from dual;

select * from DBA_CONTEXT;
select * from DBA_GLOBAL_CONTEXT;
select * from DBA_EVALUATION_CONTEXTS;
select * from DBA_EVALUATION_CONTEXT_VARS;
select * from DBA_POLICY_CONTEXTS;