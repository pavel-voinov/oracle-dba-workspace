/*
*/
@@reports.inc

column rowner format a30 heading "Group owner"
column rname format a30 heading "Group name"
column owner format a30 heading "Owner"
column name format a30 heading "Name"
column type format a30 heading "Type"

SELECT rowner, rname, owner, name, type
FROM dba_refresh_children
ORDER BY 1, 2, 3, 4
/
