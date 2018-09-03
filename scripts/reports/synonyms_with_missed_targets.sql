/*
*/
@@reports.inc
@system_users_filter.sql

column owner format a30 heading "Owner"
column synonym_name format a30 heading "Synonym"
column table_name format a30 heading "Object name"
column table_owner format a30 heading "Object owner"

SELECT s.owner, s.synonym_name, s.table_owner, s.table_name
FROM dba_synonyms s
WHERE instr(s.table_name, '/') = 0
  AND db_link is null
  AND not exists (SELECT null FROM dba_objects o WHERE o.owner = s.table_owner AND o.object_name = s.table_name)
  AND not regexp_like(owner, :v_sys_users_regexp)
ORDER BY 1, 2
/

