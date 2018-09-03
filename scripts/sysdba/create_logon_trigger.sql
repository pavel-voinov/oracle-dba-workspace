set echo off verify on

define p_user=&1
define p_schema=&2

set termout off
column p_schema new_value p_schema
SELECT upper('&p_schema') as p_schema FROM dual;
set termout on

CREATE OR REPLACE TRIGGER &p_user..on_logon
AFTER LOGON ON &p_user..SCHEMA
begin
  if sys_context('USERENV', 'ISDBA') = 'TRUE' then
    return;
  end if;

  execute immediate 'ALTER SESSION SET CURRENT_SCHEMA=&p_schema';
end on_logon;
/
show errors
