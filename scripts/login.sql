define _editor=vim

set serveroutput on size unlimited format wrapped verify off

whenever sqlerror continue

set trimspool on
set long 2048
set linesize 250
set pagesize 9999
set numwidth 12
set arraysize 150
set feedback on

set termout off

set sqlprompt 'SQL> '

/*
Prompt contains:
<user[current schema if != username]>@<db_name>/<service_name[instance_number] if != SYS$USERS>
*/

column u new_value u
column i new_value i
column ii new_value ii
column s new_value s
column db_name new_value db_name

SELECT lower(user) || decode(sys_context('USERENV', 'CURRENT_SCHEMA'), user, '', '[' || sys_context('USERENV', 'CURRENT_SCHEMA') || ']') as u,
  sys_context('USERENV', 'DB_NAME') as db_name,
  decode(sys_context('USERENV', 'SERVICE_NAME'), 'SYS$USERS', '', '/' || sys_context('USERENV', 'SERVICE_NAME')) as s,
  '[' || sys_context('USERENV', 'INSTANCE_NAME') || ']' as i,
  '[' || sys_context('USERENV', 'INSTANCE') || ']' as ii
FROM dual
/

column sqlprompt new_value sqlprompt
SELECT case
         when length('&u@&db_name.&s.&i') > 48 then
           case
             when length('&u@&db_name.&s.&ii') > 48 then
               '&u@&db_name.&i'
             else
               '&u@&db_name.&s.&ii'
           end
         else
           '&u.@&db_name.&s.&i'
       end as sqlprompt
FROM dual
/

set sqlprompt '&sqlprompt> '
alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';

undefine u
undefine i
undefine ii
undefine s
undefine db_name

@@column_formats.sql

set termout on

set timing off
