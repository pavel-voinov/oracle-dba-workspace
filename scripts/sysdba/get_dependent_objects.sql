set serveroutput on size unlimited linesize 1024 long 32000 trimspool on newpage none

define schema='&1'

set termout off
column fmask new_value fmask
SELECT 'compile_' || lower('&schema') || '_dependent_objects.sql' as fmask FROM dual;
set termout on heading off feedback off timing off pagesize 9999 trimspool on echo off verify off newpage none long 2000000000 linesize 32767

column sql_text format a1024 word_wrapped

whenever sqlerror continue

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

PROMPT Commands to compile dependent objects - &fmask
spool &fmask
SELECT 'ALTER ' || regexp_replace(type, '^(PACKAGE|TYPE) BODY$', '\1') || ' "' || owner || '"."' || name || '" ' || decode(type, 'INDEX', 'REBUILD', 'COMPILE') || decode(type, 'PACKAGE BODY', ' BODY', 'TYPE BODY', ' BODY') || ';' as sql_text
FROM (SELECT DISTINCT type, owner , name
      FROM dba_dependencies
      WHERE referenced_owner = upper('&schema')
      ORDER BY decode(type, 'SYNONYM', 1, 'VIEW', 2, 'TYPE', 3, 'PACKAGE', 4, 5), owner, name)
UNION ALL
SELECT 'exec dbms_mview.refresh(''"' || owner || '"."' || name || '"'', ''C'');' as sql_text
FROM (SELECT DISTINCT owner, name
      FROM dba_dependencies
      WHERE referenced_owner = upper('&schema')
        AND type = 'MATERIALIZED VIEW'
      ORDER BY owner, name)
/
SELECT dbms_metadata.get_dependent_ddl('MATERIALIZED_VIEW_LOG', master, log_owner) as sql_text
FROM (SELECT DISTINCT log_owner, master
      FROM dba_mview_logs
      WHERE log_owner = upper('&schema')
      ORDER BY 1, 2)
/
spool off

undefine schema
