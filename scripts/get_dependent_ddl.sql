/*
*/
set serveroutput on size unlimited verify off timing off feedback off linesize 32000 pagesize 0 heading off long 2000000 autotrace off newpage none termout on trimspool on

PROMPT Saving DDL for &1 of &2 into &3

set termout off

define file_name='&3'
column file_name new_value file_name
column obj_owner new_value obj_owner
column obj_name new_value obj_name
column obj_type new_value obj_type
column uobj_type new_value uobj_type

SELECT upper('&1') as uobj_type, regexp_replace(upper('&1'), '^(PACKAGE|TYPE)(_SPEC|_BODY)$', '\1') as obj_type, replace('&file_name', '$', '\$') as file_name
FROM dual
/

whenever sqlerror exit failure

SELECT owner as obj_owner, object_name as obj_name
FROM (SELECT owner, object_name
      FROM all_objects
      WHERE '"' || owner || '"."' || object_name || '"' = '&2'
        AND object_type = '&obj_type'
      UNION ALL
      SELECT log_owner, master
      FROM all_mview_logs
      WHERE '"' || log_owner || '"."' || master || '"' = '&2'
        AND '&uobj_type' = 'MATERIALIZED VIEW LOG')
WHERE rownum = 1
/

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

set termout off

spool &file_name append

REM PROMPT set serveroutput on size unlimited timing off define off scan off verify off
REM PROMPT 

SELECT regexp_replace(sql_text, '\;[[:space:]]*$', chr(10) || '/', 1, 0, 'mn') as sql_text
FROM (SELECT regexp_replace(dbms_metadata.get_dependent_ddl(replace('&uobj_type', ' ', '_'), object_name, owner),
           '^[[:space:]]*(CREATE |ALTER |GRANT |COMMENT )', '\1', 1, 0, 'im') as sql_text
      FROM (SELECT owner, object_name
            FROM all_objects
            WHERE owner = '&obj_owner' AND object_name = '&obj_name'
            UNION ALL
            SELECT log_owner, master
            FROM all_mview_logs
            WHERE log_owner = '&obj_owner' AND master = '&obj_name' AND '&uobj_type' = 'MATERIALIZED VIEW LOG'))
/

set termout on

spool off

exit
