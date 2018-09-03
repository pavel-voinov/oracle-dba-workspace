set serveroutput on size unlimited linesize 1024 pagesize 9999 timing off termout on autoprint off echo off heading off feedback off newpage none

VARIABLE l_cur_ts varchar2(32);
VARIABLE l_new_ts varchar2(32);
VARIABLE l_result REFCURSOR;

set termout off

define fmask=''
column time_stamp new_value fmask

SELECT to_char(sysdate, 'YYYYMMDDHH24MISS') as time_stamp FROM dual
/

spool /tmp/move_objects_todo_&fmask..sql

column sql_text format a1024 word_wrapped

REM alter session enable parallel dml;
REM commit;

set termout on

PROMPT PROMPT Run DML to move tables and indexes from &1 tablespace to &2..

PROMPT set echo on timing on

begin
  SELECT nvl(upper('&1'), 'USERS'), upper('&2') INTO :l_cur_ts, :l_new_ts
  FROM user_users WHERE username = USER;

  if :l_new_ts is null OR :l_new_ts = :l_cur_ts then
    raise_application_error(-20000, 'New tablespace must be specified and not equals to current tablespace');
  end if;

  OPEN :l_result FOR
    SELECT 'ALTER TABLE "' || table_name || '" MOVE TABLESPACE "' || :l_new_ts || '"' || chr(10) || '/' as sql_text
    FROM all_tables
    WHERE owner = user
      AND tablespace_name = :l_cur_ts
      AND temporary = 'N'
      AND iot_type is null
      AND secondary = 'N'
      AND partitioned = 'NO';
end;
/

PROMPT --Tables to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER INDEX "' || index_name || '" REBUILD TABLESPACE "' || :l_new_ts || '"' || chr(10) || '/' as sql_text FROM all_indexes
    WHERE owner = user
      AND tablespace_name = :l_cur_ts
      AND index_type like '%NORMAL%'
      AND temporary = 'N'
      AND partitioned = 'NO';
end;
/

PROMPT --Indexes to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER TABLE "' || table_name || '" MOVE LOB ("' || column_name || '") STORE AS (TABLESPACE "' || :l_new_ts || '")' || chr(10) || '/' as sql_text
    FROM all_lobs
    WHERE owner = user
      AND tablespace_name = :l_cur_ts
      AND partitioned = 'NO';
end;
/

PROMPT --LOB fields to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER TABLE "' || table_name || '" MOVE PARTITION "' || partition_name || '" TABLESPACE "' || :l_new_ts || '" UPDATE GLOBAL INDEXES' || chr(10) || '/' as sql_text
    FROM all_tab_partitions
    WHERE table_owner = user
      AND tablespace_name = :l_cur_ts;
end;
/

PROMPT --Table partitions to move:
PRINT l_result

begin
  OPEN :l_result FOR
    SELECT 'ALTER INDEX "' || index_name || '" REBUILD PARTITION "' || partition_name || '" NOLOGGING PARALLEL' || chr(10) || '/' as sql_text
    FROM all_ind_partitions
    WHERE index_owner = user
      AND tablespace_name = :l_cur_ts;
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

