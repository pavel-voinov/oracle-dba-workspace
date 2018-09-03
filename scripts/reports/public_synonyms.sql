/*
*/
@@reports.inc

column db_link format a60 heading "Link name"
column synonym_name format a30 heading "Synonym"
column table_name format a30 heading "Object name"
column table_owner format a30 heading "Object owner"

SELECT synonym_name, table_owner, table_name, db_link
FROM dba_synonyms
WHERE owner = 'PUBLIC'
  AND instr(synonym_name, '/') = 0 -- exclude java synonyms
ORDER BY 1
/

