/*
*/
@@reports.inc

column profile format a30 heading "Profile name"
column resource_name format a30 heading "Resource name"
column resource_type format a30 heading "Resource type"
column limit format a30 heading "Limited value"


SELECT profile, resource_type, resource_name, limit
FROM dba_profiles
ORDER BY 1, 2, 3
/

