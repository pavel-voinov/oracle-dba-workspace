/*
*/
set serveroutput on timing off echo off verify off linesize 180 feedback off

define p_dest1=&1
define p_dest2=&2

PROMPT ================================================================
PROMPT = CURRENT PARAMETER VALUES: ====================================
PROMPT ================================================================
column name format a25
column value format a150 word_wrap
SELECT name, value
FROM v$parameter
WHERE name in ('log_archive_dest_1', 'log_archive_dest_state_1', 'log_archive_dest_4', 'log_archive_dest_state_4')
ORDER BY name
/
PROMPT ================================================================
PROMPT
declare
  procedure exec_SQL (
    p_SQL varchar2)
  is
  begin
    dbms_output.put_line(p_SQL || chr(10) || '/');
    execute immediate p_SQL;
  end;
begin
  dbms_output.enable(null);
  exec_SQL('ALTER SYSTEM SET log_archive_dest_1=''LOCATION=&p_dest1 VALID_FOR=(ONLINE_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=' || sys_context('USERENV', 'DB_UNIQUE_NAME') || ' REOPEN=30 MAX_FAILURE=3 ALTERNATE=LOG_ARCHIVE_DEST_4'' SCOPE=BOTH SID=''*''');
  exec_SQL('ALTER SYSTEM SET log_archive_dest_state_1=ENABLE SCOPE=BOTH SID=''*''');
  exec_SQL('ALTER SYSTEM SET log_archive_dest_4=''LOCATION=&p_dest2 VALID_FOR=(ONLINE_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=' || sys_context('USERENV', 'DB_UNIQUE_NAME') || ''' SCOPE=BOTH SID=''*''');
  exec_SQL('ALTER SYSTEM SET log_archive_dest_state_4=ALTERNATE SCOPE=BOTH SID=''*''');
end;
/

set feedback on
