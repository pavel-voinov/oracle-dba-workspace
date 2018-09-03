set serveroutput on size unlimited

define schema='&1'

begin
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true);
end;
/
set termout off
column fmask new_value fmask
SELECT lower('&schema') || '_system_privs.sql' as fmask FROM dual;
set termout on heading off feedback off timing off pagesize 9999 trimspool on echo off verify off newpage none

PROMPT System grants will be saved in &fmask
spool &fmask
SELECT dbms_metadata.get_granted_ddl('SYSTEM_GRANT', upper('&schema'))
FROM dual
/
spool off
host sed -i -r '/^\s*$/d;s/^\s*//g' &fmask
