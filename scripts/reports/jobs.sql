/*
*/
@@reports.inc

column schema_user format a30 heading "Owner"
column broken format a6 heading "Broken"
column what format a140 heading "Job action" word_wrapped

SELECT schema_user, broken, trim(what) as what
FROM dba_jobs
ORDER BY 1, 3
/
