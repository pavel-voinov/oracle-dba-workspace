/*

Creating audit purge job:
*/
exec dbms_audit_mgmt.init_cleanup(dbms_audit_mgmt.AUDIT_TRAIL_ALL, 720);
exec dbms_audit_mgmt.create_purge_job(dbms_audit_mgmt.AUDIT_TRAIL_ALL, 720, 'PURGE_AUDIT');

/*
To check status of job and look at cleanup events history:

SQL> select * from dba_audit_mgmt_cleanup_jobs;
SQL> select * from dba_audit_mgmt_clean_events;
*/
