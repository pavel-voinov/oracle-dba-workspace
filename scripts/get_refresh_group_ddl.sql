set serveroutput on size unlimited verify off timing off feedback off linesize 32000 pagesize 0 heading off long 2000000 autotrace off newpage none termout on trimspool on


PROMPT Saving DDL for &1 into &2

set termout off

define file_name='&2'
column file_name new_value file_name
column obj_owner new_value obj_owner
column obj_name new_value obj_name

SELECT replace('&file_name', '$', '\$') as file_name
FROM dual
/

whenever sqlerror exit failure

SELECT rowner as obj_owner, rname as obj_name
FROM all_refresh
WHERE '"' || rowner || '"."' || rname || '"' = '&1'
  AND rownum = 1
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

PROMPT set serveroutput on size unlimited timing off define off scan off verify off
PROMPT 

SELECT sql_text
FROM (SELECT to_clob('begin' || chr(10) ||
        '  dbms_refresh.make(name => ''"' || rowner || '"."' || rname || '"'', list => null, next_date => null, interval => null, implicit_destroy => ' || decode(implicit_destroy, 'Y', 'true', 'false') || ', refresh_after_errors => ' || decode(refresh_after_errors, 'Y', 'true', 'false') || ', purge_option => ' || purge_option || decode(parallelism, 0, null, null, null, ', parallelism => ' || parallelism) || ');' || chr(10) ||
        '  commit;' || chr(10) ||
        'end;' || chr(10) ||
        '/') as sql_text
      FROM all_refresh
      WHERE rowner = '&obj_owner' AND rname = '&obj_name'
      UNION ALL
      SELECT to_clob('begin' || chr(10) ||
        '  dbms_refresh.add(name => ''"' || rowner || '"."' || rname || '"'', list => ''"' || owner || '"."' || name || '"'', lax => true);' || chr(10) ||
        '  commit;' || chr(10) ||
        'end;' || chr(10) ||
        '/')
      FROM all_refresh_children
      WHERE rowner = '&obj_owner' AND rname = '&obj_name')
/

set termout on

spool off

exit
