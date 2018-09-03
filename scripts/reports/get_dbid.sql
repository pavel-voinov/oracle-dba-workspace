/*
*/
set serveroutput on size unlimited verify off timing off feedback off linesize 32000 pagesize 0 heading off long 2000000 autotrace off newpage none termout on trimspool on
column dbid format 99999999999990
SELECT dbid FROM v$database;
