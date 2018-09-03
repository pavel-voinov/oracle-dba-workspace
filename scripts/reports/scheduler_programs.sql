/*
*/
@@reports.inc

column owner format a30 heading "Owner"
column program_name format a30 heading "Name"
column program_type format a16 heading "Type"
column enabled format a8 heading "Enabled"
column detached format a8 heading "Detached"
column priority format 9990 heading "Priority"
column number_of_arguments format 9990 heading "Arguments"
column comments format a150 heading "Comments" newline word_wrapped

SELECT owner, program_name, program_type, number_of_arguments, enabled, detached, priority, comments --program_action
FROM dba_scheduler_programs
ORDER BY 1, 2
/
