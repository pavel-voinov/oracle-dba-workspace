/*
*/
@@reports.inc
@system_users_filter.sql

column owner format a30 heading "Owner"
column synonym_name format a30 heading "Synonym"
column table_name format a30 heading "Object name"
column table_owner format a30 heading "Object owner"
column db_link format a36 heading "DB Link"

SELECT s.owner, s.synonym_name, s.table_owner, s.table_name, s.db_link
FROM dba_synonyms s
WHERE instr(s.table_name, '/') = 0
  AND s.db_link is not null
  AND not exists (SELECT null FROM dba_db_links o WHERE o.owner IN (s.owner, 'PUBLIC') AND o.db_link = s.db_link)
  AND not regexp_like(s.owner, :v_sys_users_regexp)
ORDER BY 1, 2
/

