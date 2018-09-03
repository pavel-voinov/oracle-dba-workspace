set serveroutput on size unlimited verify off timing off feedback off linesize 1024 pagesize 9999 heading off long 32000 autotrace off echo off

define p_mview_name=&1

set termout off

column fname new_value fname
column p_schema new_value p_schema
column p_mview_name new_value p_mview_name

SELECT '/tmp/recreate_mview_' || lower('&p_mview_name') || '_' || to_char(sysdate, 'YYYYMMDDHH24MISS') as fname,
  sys_context('USERENV', 'CURRENT_SCHEMA') as p_schema, upper('&p_mview_name') as p_mview_name
FROM dual
/

begin
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', false);
end;
/

column sql_text format a1024 word_wrapped

spool &fname..sql

set termout on

PROMPT set echo on timing on scan off
PROMPT spool &fname..log

SELECT 'DROP MATERIALIZED VIEW ' || m.mview_name || chr(10) || '/' || chr(10) ||
  dbms_metadata.get_ddl('MATERIALIZED_VIEW', m.mview_name) || chr(10) || '' || chr(10) ||
    case (SELECT count(*) as cnt FROM all_indexes i WHERE i.owner = m.owner AND i.table_name = m.mview_name)
      when 0 then
        null
      else
        dbms_metadata.get_dependent_ddl('INDEX', m.mview_name) || chr(10) || ''
    end || chr(10) ||
    case (SELECT count(*) as cnt
          FROM all_refresh_children r
          WHERE r.owner = m.owner AND r.name = m.mview_name
            AND r.rowner || '.' || r.rname <> r.owner || '.' || r.name)
      when 0 then
        null
      else
        (SELECT 'begin ' || chr(10) || 
                '  dbms_refresh.add(name => ''"' || r.rowner || '"."' || r.rname || '"'', list => ''"' || r.owner || '"."' || r.name || '"'', lax => true);' || chr(10) ||
                '  commit;' || chr(10) ||
                'end;' || chr(10) || '/' || chr(10)
        FROM all_refresh_children r 
        WHERE r.owner = m.owner AND r.name = m.mview_name)
    end as sql_text
FROM all_mviews m
WHERE m.owner = '&p_schema' AND m.mview_name = upper('&p_mview_name')
/
SELECT 'GRANT ' || privilege || ' ON "' || table_schema || '"."' || table_name || '" TO "' || grantee || '"' || decode(grantable, 'YES', ' WITH GRANT OPTION') || ';' as sql_text
FROM all_tab_privs
WHERE table_schema = '&p_schema' AND table_name = upper('&p_mview_name')
/
SELECT 'ALTER ' || regexp_replace(type, '^(PACKAGE|TYPE) BODY$', '\1') || ' "' || owner || '"."' || name || '" ' || decode(type, 'INDEX', 'REBUILD', 'COMPILE') || decode(type, 'PACKAGE BODY', ' BODY', 'TYPE BODY', ' BODY') || ';' as sql_text
FROM (SELECT DISTINCT type, owner , name
      FROM all_dependencies
      WHERE referenced_owner = '&p_schema' AND referenced_name = '&p_mview_name'
        AND referenced_owner <> owner AND referenced_name <> name
      ORDER BY decode(type, 'SYNONYM', 1, 'VIEW', 2, 'TYPE', 3, 'PACKAGE', 4, 5), owner, name)
UNION ALL
SELECT 'exec dbms_mview.refresh(''"' || owner || '"."' || name || '"'', ''C'');' as sql_text
FROM (SELECT DISTINCT owner, name
      FROM all_dependencies
      WHERE referenced_owner = '&p_schema' AND referenced_name = '&p_mview_name'
        AND type = 'MATERIALIZED VIEW' AND referenced_owner <> owner AND referenced_name <> name
      ORDER BY owner, name)
/       
SELECT dbms_metadata.get_dependent_ddl('MATERIALIZED_VIEW_LOG', master, log_owner) as sql_text
FROM (SELECT DISTINCT log_owner, master
      FROM all_mview_logs
      WHERE log_owner = '&p_schema'
        AND master = '&p_mview_name'
      ORDER BY 1, 2)
/

PROMPT set echo off scan on
PROMPT spool off

PROMPT PROMPT Check SQL commands and log in &fname..sql and &fname..log files

set termout off

spool off

set termout on

PROMPT Press Ctrl-C to exit or any other key to execute &fname..sql script
pause
@&fname..sql

undefine schema
