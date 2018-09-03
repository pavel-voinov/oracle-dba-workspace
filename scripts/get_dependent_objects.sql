-- Source: http://www.dba-oracle.com/d_dba_dependencies.htm
set line 142 pages 60

define p_schema=&1

column display_parent format a58
column display_child format a58
column referenced_owner noprint
column referenced_object noprint
column referenced_type noprint
column owner noprint
column object noprint
column type noprint
column last_ddl_time format a22 head 'CHILD DDL TIME'

undef 1 2

with dependencies as (
        -- top down through the heirarchy
        select /*+ no_merge */
                referenced_type || ' "' || referenced_owner || '"."' ||
                referenced_name || '"' as parent,
                type || ' "' || owner || '"."' || name || '"' as child,
                level hlevel,
                referenced_owner, referenced_name, referenced_type,
                owner, name, type
        from dba_dependencies
        start with
                referenced_owner = upper('&&p_schema')
        --        and referenced_name = 'uobject'
        connect by
                referenced_owner = prior owner
                and referenced_name = prior name
                and referenced_type = prior type
        union
        -- bottom up through the heirarchy
        select /*+ no_merge */
                referenced_type || ' "' || referenced_owner || '"."' ||
                referenced_name || '"' as parent,
                type || ' "' || owner || '"."' || name || '"' as child,
                level hlevel,
                referenced_owner, referenced_name, referenced_type,
                owner, name, type
        from dba_dependencies
        start with
                owner = upper('&&p_schema')
--                and name = 'uobject'
        connect by
                owner = prior referenced_owner
                and name = prior referenced_name
                and type = prior referenced_type
        order by 1, 2
)
select lpad(' ',2*d.hlevel,' ') || d.parent display_parent, d.child 
display_child, o.last_ddl_time 
from dependencies d, dba_objects o
where o.owner = d.owner
and o.object_type = d.type
and d.name = o.object_name
order by parent, child
/
