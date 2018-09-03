/*
*/
@reports/reports_header

define schema=&1

column mview_name format a30 heading "MView name"
column refresh_mode format a13 heading "Refresh mode"
column refresh_method format a15 heading "Refresh method"
column build_mode format a13 heading "Build mode"
column query_len format 99999990 heading "Length of query text"
column status format a10 heading "Status"
column compile_state format a15 heading "Compile state"
column staleness format a15 heading "Staleness"
column fast_refreshable format a15 heading "Fast|Refreshable"

SELECT v.mview_name, v.query_len, v.refresh_mode, v.refresh_method, v.build_mode, v.fast_refreshable--, v.compile_state, o.status, v.staleness
FROM dba_mviews v, dba_objects o
WHERE v.owner = '&schema' AND o.owner = v.owner AND o.object_type = 'MATERIALIZED VIEW' AND o.object_name = v.mview_name
ORDER BY 1
/
