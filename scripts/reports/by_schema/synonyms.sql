/*
*/
@reports/reports_header

define schema=&1

column synonym_name format a30 heading "Synonym name"
column table_name format a60 heading "Table name"
column db_link format a50 heading "DB Link"
column status format a10 heading "Status"

SELECT t.synonym_name, decode(t.table_owner, t.owner, '', t.table_owner || '.') || t.table_name as table_name, t.db_link, o.status
FROM dba_synonyms t, dba_objects o
WHERE t.owner = '&schema' AND o.owner = t.owner AND o.object_type = 'SYNONYM' AND o.object_name = t.synonym_name
ORDER BY 1
/
