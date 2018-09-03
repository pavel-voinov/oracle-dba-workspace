set serveroutput on size unlimited linesize 4000 pagesize 9999 timing off termout on autoprint off echo off heading off feedback off newpage none verify off

define schema=&1;

VARIABLE l_default_ts varchar2(32);
VARIABLE l_default_temp_ts varchar2(32);
VARIABLE l_result REFCURSOR;

set termout off

define fmask=''
column time_stamp new_value fmask

SELECT to_char(sysdate, 'YYYYMMDDHH24MISS') as time_stamp FROM dual
/

spool /tmp/move_objects_todo_&fmask..sql

column sql_text format a4000 word_wrapped

REM alter session enable parallel dml;

set termout on

PROMPT PROMPT Get SQL to move tables and indexes to default tablespace.

PROMPT set echo on timing on

declare
  cursor c_Defaults is
    SELECT default_tablespace, temporary_tablespace
    FROM dba_users
    WHERE username = upper('&schema');
begin
  open c_Defaults;
  fetch c_Defaults INTO :l_default_ts, :l_default_temp_ts;
  close c_Defaults;

  if :l_default_ts is null then
    raise_application_error(-20000, 'User &schema is not found');
  end if;

  OPEN :l_result FOR
    SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" MOVE TABLESPACE "' || :l_default_ts || '"' || chr(10) || '/' as sql_text
    FROM dba_tables
    WHERE owner = upper('&schema')
      AND nvl(tablespace_name, 'TEMP') <> :l_default_ts
      AND temporary = 'N'
--      AND iot_type is null
      AND partitioned = 'NO';
end;
/

PROMPT --Tables to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER INDEX "' || owner || '"."' || index_name || '" REBUILD TABLESPACE "' || :l_default_ts || '"' || chr(10) || '/' as sql_text
    FROM dba_indexes
    WHERE owner = upper('&schema')
      AND decode(tablespace_name, :l_default_ts, 1, :l_default_temp_ts, 1, 0) = 0
      AND not regexp_like(index_type, '(DOMAIN|IOT - TOP)')
      AND temporary = 'N'
      AND partitioned = 'NO';
end;
/

PROMPT --Indexes to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" MOVE LOB ("' || column_name || '") STORE AS (TABLESPACE "' || :l_default_ts || '")' || chr(10) || '/' as sql_text
    FROM dba_lobs
    WHERE owner = upper('&schema')
      AND decode(tablespace_name, :l_default_ts, 1, :l_default_ts || '_LOB', 1, :l_default_temp_ts, 1, 0) = 0
      AND partitioned = 'NO';
end;
/

PROMPT --LOB fields to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER TABLE "' || table_owner || '"."' || table_name || '" MOVE PARTITION "' || partition_name || '" TABLESPACE "' || :l_default_ts || '" UPDATE GLOBAL INDEXES' || chr(10) || '/' as sql_text
    FROM dba_tab_partitions
    WHERE table_owner = upper('&schema')
      AND nvl(tablespace_name, 'TEMP') <> :l_default_ts;
end;
/

PROMPT --Table partitions to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER INDEX "' || index_owner || '"."' || index_name || '" REBUILD PARTITION "' || partition_name || '" TABLESPACE "' || :l_default_ts || '" NOLOGGING PARALLEL' || chr(10) || '/' as sql_text
    FROM dba_ind_partitions
    WHERE index_owner = upper('&schema')
      AND nvl(tablespace_name, 'TEMP') <> :l_default_ts;
end;
/

PROMPT --Index partitions to move:
PRINT l_result

set termout off

spool off

set termout on

PROMPT Press Ctrl-C to exit or any other key to execute move_objects_todo_&fmask..sql script
pause
@/tmp/move_objects_todo_&fmask..sql

undefine schema
