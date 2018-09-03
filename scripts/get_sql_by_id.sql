/*

Script to make <sql_id>.sql based on v$sql sql_fulltext content
*/
set serveroutput on size unlimited echo off verify off heading off feedback off timing off autotrace off linesize 32000 pagesize 9999 long 32000 newpage none

define sql_id=&1

column sql_fulltext format a32000

spool &sql_id..sql

SELECT sql_fulltext || chr(10) || '/' as sql_fulltext
FROM (SELECT sql_fulltext
      FROM v$sql
      WHERE lower(sql_id) = lower('&sql_id')
      ORDER BY last_active_time DESC)
WHERE rownum = 1
/

spool off

exit
