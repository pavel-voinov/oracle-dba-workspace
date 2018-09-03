/*
*/
@@reports.inc

column id format 99999999 heading "ID"
column namespace format a15 heading "Namespace"
column version format a23 heading "Version" word_wrapped
column action format a20 heading "Action"
column bundle_series format a10 heading "Bundle"
column Comments format a80 heading "Comments" word_wrapped

SELECT bundle_series, namespace, action, namespace, version, id, comments
FROM sys.registry$history
ORDER BY action_time
/
