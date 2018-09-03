/*
*/
@@reports.inc

column owner format a30 heading "Owner"
column master_link format a35 heading "Link name"
column mview_name format a30 heading "Materialized view"

SELECT owner, mview_name, regexp_replace(master_link, '(@|\")') as master_link
FROM dba_mviews
WHERE master_link is not null
ORDER BY 1, 2
/

