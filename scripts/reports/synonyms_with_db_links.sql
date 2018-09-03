/*
*/
@@reports.inc

column owner format a30 heading "Owner"
column db_link format a40 heading "Link name"
column synonym_name format a30 heading "Synonym"
column table_name format a30 heading "Object name"
column table_owner format a30 heading "Object owner"

SELECT owner, synonym_name, table_owner, table_name, db_link
FROM dba_synonyms
WHERE db_link is not null
ORDER BY 1, 2
/

