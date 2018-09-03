/*
*/
@@reports.inc

column sid format a10 heading "SID"
column name format a38 heading "Name"
column value format a90 heading "Value"
column isspecified format a9 heading "Specified"

SELECT name, value, isspecified
FROM v$spparameter
WHERE sid = '*'
  AND regexp_like(name, '^(service_names|remote_listener|log_archive_dest.*|dispatchers|db_(|unique_)name|instance_name|control_files|cluster_database_instances|audit_file_dest|dg_broker.*|.*_file_name_convert|fal_(server|client)|log_archive_config|standby_file_management)$')
ORDER BY name, sid
/
