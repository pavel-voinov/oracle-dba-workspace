set serveroutput on size unlimited linesize 300 long 32000 trimspool on newpage none

define schema='&1'

begin
  dbms_output.enable(null);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', false);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true);
end;
/

set termout off

column fmask new_value fmask

SELECT 'privs_granted_to_' || lower('&schema') || '.sql' as fmask FROM dual;

set termout on heading off feedback off timing off pagesize 0 trimspool on echo off verify off newpage none linesize 300

column privs format a300 word_wrapped

whenever sqlerror continue

PROMPT Object grants will be saved in &fmask

spool &fmask

SELECT dbms_metadata.get_granted_ddl('OBJECT_GRANT', upper('&schema')) as privs FROM dual;

spool off

host sed -i -r '/^\s*$/d;s/^\s*//g' &fmask

undefine schema

