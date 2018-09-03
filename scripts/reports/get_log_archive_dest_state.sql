/*
*/
set serveroutput on timing off echo off verify off linesize 180 feedback off

column name format a25
column value format a150 word_wrap
SELECT name, value
FROM v$parameter
WHERE name like 'log_archive_dest_%'
ORDER BY to_number(regexp_replace(name, '^log_archive_dest.*_')), instr(name, 'state')
/
