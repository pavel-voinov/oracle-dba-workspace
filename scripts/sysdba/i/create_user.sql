/*
*/
set serveroutput on size 1000000 verify off feedback off timing off termout on echo off

ACCEPT schema PROMPT 'Enter username: '
column lschema new_value lschema
set termout off
SELECT lower('&schema') as lschema FROM dual;
set termout on
ACCEPT pass DEFAULT '&lschema' PROMPT 'Enter password [&lschema]: '
ACCEPT tbs DEFAULT 'USERS' PROMPT 'Enter default tablespace for user [USERS]: '

column tbs new_value tbs
column pass new_value pass
set termout off
SELECT nvl(upper('&tbs'), 'USERS') as tbs, nvl('&pass', '&lschema') as pass FROM dual;
set termout on

@sysdba/p/create_user.sql
