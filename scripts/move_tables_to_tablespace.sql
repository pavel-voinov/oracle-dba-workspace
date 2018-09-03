set serveroutput on size 100000 linesize 130 pagesize 9999 timing off termout on autoprint off heading off verify off

PROMPT PROMPT Altering segments &1:

SELECT 'ALTER TABLE "' || table_name || '" MOVE TABLESPACE "&2";' as sql_text
FROM all_tables
WHERE owner = user AND
      tablespace_name <> upper('&2') AND
      temporary = 'N' AND
      iot_type is null AND
      secondary = 'N' AND
      table_name like upper('&1')
/

SELECT 'ALTER INDEX "' || index_name || '" REBUILD TABLESPACE "&2";' as sql_text
FROM all_indexes
WHERE owner = user AND
      tablespace_name <> upper('&2') AND
      index_type = 'NORMAL' AND temporary = 'N' AND
      table_name like upper('&1')
/

SELECT 'ALTER TABLE "' || table_name || '" MOVE LOB ("' || column_name || '") STORE AS (TABLESPACE "&2");' as sql_text
FROM all_lobs
WHERE owner = user AND
      tablespace_name <> upper('&2') AND
      table_name like upper('&1')
/
