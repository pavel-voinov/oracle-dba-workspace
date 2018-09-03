set serveroutput on size unlimited linesize 4000 pagesize 9999 timing off termout on autoprint off echo off heading off feedback off newpage none verify off

define schema=&1
define ts=&2

VARIABLE l_ts varchar2(32);
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

PROMPT PROMPT Get SQL to move segments of schema &schema to tablespace &ts..

PROMPT set echo on timing on

declare
  cursor c_TS is
    SELECT tablespace_name
    FROM dba_tablespaces
    WHERE tablespace_name = upper('&ts');
begin
  open c_TS;
  fetch c_TS INTO :l_ts;
  close c_TS;

  if :l_ts is null then
    raise_application_error(-20000, 'Target tablespace &ts is not found');
  end if;

  OPEN :l_result FOR
    SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" MOVE TABLESPACE "' || :l_ts || '"' || chr(10) || '/' as sql_text
    FROM dba_tables
    WHERE owner = upper('&schema')
      AND nvl(tablespace_name, 'TEMP') <> :l_ts
      AND temporary = 'N'
--      AND iot_type is null
      AND partitioned = 'NO';
end;
/

PROMPT -- Tables to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER INDEX "' || owner || '"."' || index_name || '" REBUILD TABLESPACE "' || :l_ts || '"' || chr(10) || '/' as sql_text
    FROM dba_indexes
    WHERE owner = upper('&schema')
      AND nvl(tablespace_name, 'TEMP') <> :l_ts
      AND index_type like '%NORMAL%'
      AND temporary = 'N'
      AND partitioned = 'NO';
end;
/

PROMPT -- Indexes to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" MOVE LOB ("' || column_name || '") STORE AS (TABLESPACE "' || :l_ts || '")' || chr(10) || '/' as sql_text
    FROM dba_lobs
    WHERE owner = upper('&schema')
      AND nvl(tablespace_name, 'TEMP') <> :l_ts
      AND partitioned = 'NO';
end;
/

PROMPT -- LOB segments to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER TABLE "' || table_owner || '"."' || table_name || '" MOVE PARTITION "' || partition_name || '" TABLESPACE "' || :l_ts || '" UPDATE GLOBAL INDEXES' || chr(10) || '/' as sql_text
    FROM dba_tab_partitions
    WHERE table_owner = upper('&schema')
      AND nvl(tablespace_name, 'TEMP') <> :l_ts;
end;
/

PROMPT -- Table partitions to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER INDEX "' || index_owner || '"."' || index_name || '" REBUILD PARTITION "' || partition_name || '" TABLESPACE "' || :l_ts || '" NOLOGGING PARALLEL' || chr(10) || '/' as sql_text
    FROM dba_ind_partitions
    WHERE index_owner = upper('&schema')
      AND nvl(tablespace_name, 'TEMP') <> :l_ts;
end;
/

PROMPT -- Index partitions to move:
PRINT l_result

set termout off

spool off

set termout on

PROMPT Press Ctrl-C to exit or any other key to execute move_objects_todo_&fmask..sql script
pause
@/tmp/move_objects_todo_&fmask..sql

undefine schema
undefine ts
