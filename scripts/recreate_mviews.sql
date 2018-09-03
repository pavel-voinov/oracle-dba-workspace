set serveroutput on size unlimited verify off timing off feedback off linesize 1024 pagesize 9999 heading off long 32000 autotrace off echo off

set termout off

define fmask=''
column time_stamp new_value fmask

SELECT to_char(sysdate, 'YYYYMMDDHH24MISS') as time_stamp FROM dual
/

begin
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
end;
/

column sql_text format a1024 word_wrapped

spool /tmp/mviews_todo_&fmask..sql

set termout on

PROMPT set echo on timing on scan off
PROMPT spool /tmp/mviews_todo_&fmask..log

SELECT
  CASE m.staleness
    WHEN 'IMPORT' THEN
      'DROP MATERIALIZED VIEW ' || m.mview_name || chr(10) || '/' || chr(10) ||
      dbms_metadata.get_ddl('MATERIALIZED_VIEW', m.mview_name) || chr(10) || '' || chr(10) ||
      case (SELECT count(*) as cnt FROM all_indexes i WHERE i.owner = m.owner AND i.table_name = m.mview_name)
        when 0 then
          null
        else
          dbms_metadata.get_dependent_ddl('INDEX', m.mview_name) || chr(10) || ''
      end
    WHEN 'COMPILATION_ERROR' THEN
      'DROP MATERIALIZED VIEW ' || m.mview_name || chr(10) || '/' || chr(10) ||
      dbms_metadata.get_ddl('MATERIALIZED_VIEW', m.mview_name) || chr(10) || '' || chr(10) ||
      case (SELECT count(*) as cnt FROM all_indexes i WHERE i.owner = m.owner AND i.table_name = m.mview_name)
        when 0 then
          null
        else
          dbms_metadata.get_dependent_ddl('INDEX', m.mview_name) || chr(10) || ''
      end
    WHEN 'NEEDS_COMPILE' THEN
      to_clob('ALTER MATERIALIZED VIEW ' || m.mview_name || ' COMPILE' || chr(10) || '/')
    ELSE
      to_clob('exec dbms_mview.refresh(''' || m.mview_name || ''');')
    END as sql_text
FROM user_mviews m
WHERE m.staleness IN ('IMPORT', 'NEEDS_COMPILE', 'COMPILATION_ERROR', 'STALE', 'UNUSABLE')
ORDER BY decode(m.staleness, 'IMPORT', 1, 'NEEDS_COMPILE', 2, 'COMPILATION_ERROR', 3, 4)
/

PROMPT set echo off scan on
PROMPT spool off

PROMPT host rm -i /tmp/mviews_todo_&fmask..sql

set termout off

spool off

set termout on

PROMPT Press Ctrl-C to exit or any other key to start mviews_todo_&fmask..sql script
pause
@/tmp/mviews_todo_&fmask..sql
