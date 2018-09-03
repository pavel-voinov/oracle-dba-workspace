set serveroutput on size unlimited verify off timing off feedback off linesize 32000 pagesize 0 heading off long 2000000 autotrace off newpage none termout on trimspool on


PROMPT Saving DDL for role &1 into &2

set termout off

define file_name='&2'
column file_name new_value file_name
column rolename new_value rolename
column uobj_type new_value uobj_type

SELECT upper('&1') as rolename, replace('&file_name', '$', '\$') as file_name
FROM dual
/

whenever sqlerror exit failure

begin
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', false);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'CONSTRAINTS', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'CONSTRAINTS_AS_ALTER', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'OID', false);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'FORCE', true);
end;
/
column sql_text format a32000 word_wrapped

variable rep REFCURSOR

set termout off

spool &file_name append

REM PROMPT set serveroutput on size unlimited timing off define off scan off verify off
REM PROMPT 

SELECT regexp_replace(sql_text, '\;[[:space:]]*$', chr(10) || '/', 1, 0, 'mn') as sql_text
FROM (SELECT dbms_metadata.get_ddl('ROLE', '&rolename') as sql_text
      FROM dba_roles
      WHERE role = '&rolename'
      UNION ALL
      SELECT dbms_metadata.get_granted_ddl('ROLE_GRANT', '&rolename') as sql_text
      FROM dual
      WHERE exists (SELECT null FROM dba_role_privs WHERE grantee = '&rolename')
      UNION ALL
      SELECT dbms_metadata.get_granted_ddl('SYSTEM_GRANT', '&rolename') as sql_text
      FROM dual
      WHERE exists (SELECT null FROM dba_sys_privs WHERE grantee = '&rolename'))
/

set termout on

spool off

exit
