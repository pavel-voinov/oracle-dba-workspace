set serveroutput on size unlimited verify off timing off feedback off linesize 32000 pagesize 0 heading off long 2000000 autotrace off newpage none termout on trimspool on


PROMPT Saving DDL for database link &1 into &2

set termout off

define file_name='&2'
column file_name new_value file_name
column obj_owner new_value obj_owner
column obj_name new_value obj_name

SELECT replace('&file_name', '$', '\$') as file_name
FROM dual
/

whenever sqlerror exit failure

SELECT owner as obj_owner, db_link as obj_name
FROM all_db_links
WHERE '"' || owner || '"."' || db_link || '"' = '&1'
  AND rownum = 1
/

whenever sqlerror exit failure

begin
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true);
end;
/
column sql_text format a32000 word_wrapped

set termout off

spool &file_name append

REM PROMPT set serveroutput on size unlimited timing off define off scan off verify off
REM PROMPT 

SELECT regexp_replace(regexp_replace(sql_text, '\;[[:space:]]*$', chr(10) || '/', 1, 0, 'mn'),
  '^[[:space:]]*((CREATE|USING|CONNECT) .*)$', '\1', 1, 0, 'im') as sql_text
FROM (
  SELECT dbms_metadata.get_ddl('DB_LINK', db_link, owner) as sql_text
  FROM all_db_links
  WHERE owner = '&obj_owner' AND db_link = '&obj_name'
)
/

set termout on

spool off

exit
