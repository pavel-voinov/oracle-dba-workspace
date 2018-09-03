/*
*/
@@reports.inc

column owner format a30 heading "Owner"
column table_name format a30 heading "Table name"
column log_group_name format a30 heading "Name"
column log_group_type format a30 heading "Type"
column always format a12 heading "Always"

define p_schema=&1

--TTITLE "Tables with assigned log groups"
--SELECT DISTINCT table_name, decode(generated, 'USER NAME', log_group_name, '*GENERATED*') as log_group_name, log_group_type, always
--FROM dba_log_groups
--WHERE owner = upper('&p_schema')
--ORDER BY 1, 2
--/
TTITLE "Tables without assigned log groups"
SELECT table_name
FROM dba_tables
WHERE owner = upper('&p_schema')
  AND secondary = 'N'
  AND temporary = 'N'
MINUS
SELECT table_name
FROM dba_log_groups
WHERE owner = upper('&p_schema')
ORDER BY 1
/
TTITLE "Tables and supplemental log groups"
column x format a30 heading ""
column cnt format 9999990 heading "Count"
SELECT decode(log_group_name, null, 'Tables without log groups', 'Tables with log groups') as x, count(*) as cnt
FROM (SELECT DISTINCT t.table_name, l.log_group_name
      FROM dba_tables t, dba_log_groups l
      WHERE t.owner = upper('&p_schema')
        AND t.secondary = 'N'
        AND t.temporary = 'N'
        AND t.owner = l.owner(+)
        AND t.table_name = l.table_name(+))
GROUP BY decode(log_group_name, null, 'Tables without log groups', 'Tables with log groups')
ORDER BY 1
/

TTITLE off
