set serveroutput on size 1000000 verify off feedback off timing off termout on echo off

ACCEPT p_schema PROMPT 'Enter username: '
column pwd new_value pwd
column tbs new_value tbs
set termout off
SELECT lower('&p_schema') as pwd, substr(upper('&p_schema'), 1, 27) || '_DATA' as tbs FROM dual;
set termout on
ACCEPT p_password CHAR DEFAULT "&pwd" PROMPT 'Enter password [&pwd]: ' HIDE
ACCEPT p_tablespace CHAR DEFAULT "&tbs" PROMPT 'Enter default tablespace for user [&tbs]: '
--ACCEPT jcart_owner PROMPT 'Enter JChem cartridge owner (if required): '

undefine pwd

@sysdba/p/create_schema.sql

set feedback on timing on
