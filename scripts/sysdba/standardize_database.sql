/*

Call for set of scripts to standardize databases (for LION, first of all)
*/
set echo on

@sysdba/fix_bug_on_import_timestamp_with_timezone.sql

@sysdba/setup_rdbms_parameters.sql
@sysdba/setup_xdb.sql

@sysdba/audit/basic_db_on.sql
@sysdba/audit/create_cleanup_job.sql

@sysdba/disable_default_profile_limits.sql
@sysdba/sec_case_sensitive_logon.sql

@sysdba/make_all_tablespaces_autoxtensible.sql
