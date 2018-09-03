/*
*/
@@reports.inc

column schema format a30 heading "Schema name"
column app_user format a15 heading "Has App User"
column loader_user format a15 heading "Has Loader user"

SELECT schema, app_user, loader_user
FROM db_deployment.lm_schemas
ORDER BY 1
/
