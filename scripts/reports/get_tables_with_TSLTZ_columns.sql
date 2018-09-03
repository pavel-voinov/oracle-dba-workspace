/*
Timestamps & time zones - Frequently Asked Questions (Doc ID 340512.1)
*/
select c.owner || '.' || c.table_name || '(' || c.column_name || ') - ' || c.data_type || ' ' col
from dba_tab_cols c, dba_objects o
where c.data_type like '%WITH LOCAL TIME ZONE'
and c.owner=o.owner
and c.table_name = o.object_name
and o.object_type = 'TABLE'
order by col
/

select DISTINCT c.owner || '.' || c.table_name as table_name
from dba_tab_cols c, dba_objects o
where c.data_type like '%WITH LOCAL TIME ZONE'
and c.owner=o.owner
and c.table_name = o.object_name
and o.object_type = 'TABLE'
order by 1
/
