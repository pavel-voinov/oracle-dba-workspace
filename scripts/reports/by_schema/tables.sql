/*
*/
@reports/reports_header

define schema=&1

column table_name format a30 heading "Table name"
column tablespace_name format a30 heading "Tablespace name"
column iot_name format a20 heading "IOT Name"
column partitioned format a11 heading "Partitioned"
column temporary format a6 heading "Temp"
column secondary format a10 heading "Secondary"
column compression format a11 heading "Compression"
column iot_type format a15 heading "IOT Type"

SELECT nvl(iot_name, table_name) as table_name, tablespace_name, temporary, secondary, partitioned, compression, iot_type
FROM dba_tables
WHERE owner = '&schema' AND dropped = 'NO'
ORDER BY 1
/
