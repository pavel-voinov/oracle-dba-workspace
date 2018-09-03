/*
*/
set serveroutput on timing on

ACCEPT p_schema PROMPT "Schema name to copy: "
ACCEPT p_db_link PROMPT "Database link name to source database: "

set termout off
column scn new_value scn
SELECT min(current_scn) as scn FROM gv$database@&db_link;
set termout on

whenever sqlerror exit failure
begin
  if length('&scn') = 0 then
    raise_application_error(-20001, 'DB Link is not working or SCN cannot be received from source database');
  end if;
end;
/

PROMPT
PROMPT ===============================================
PROMPT You have selected:
PROMPT ===============================================
PROMPT  Schema(s): &p_schema
PROMPT    DB Link: &p_db_link
PROMPT        SCN: &p_scn
PROMPT

ACCEPT p_continue DEFAULT 'Y' PROMPT "Do you want to continue with parameters above (Y/N). [Y]: "

set term off
column p_script_name new_value p_script_name
SELECT decode(nvl(upper(substr('&p_continue', 1, 1)), 'Y'), 'Y', 'sysdba/p/copy_schema_by_db_link.sql', 'cancel.sql') as p_script_name FROM dual;
set term on

@&p_script_name
