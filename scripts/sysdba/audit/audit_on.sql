/*
*/
ALTER SYSTEM SET audit_trail=DB SCOPE=SPFILE SID='*';
ALTER SYSTEM SET audit_sys_operations=TRUE SCOPE=SPFILE SID='*';

@@create_cleanup_job.sql
