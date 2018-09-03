Use the CREATE_STGTAB_SQLPROF procedure to create a staging table where the SQL profiles will be exported.

The following example creates my_staging_table in the DBA1 schema:

BEGIN
  DBMS_SQLTUNE.create_stgtab_sqlprof( 
    table_name  => 'my_staging_table',
    schema_name => 'DBA1' );
END;
/
Use the PACK_STGTAB_SQLPROF procedure to export SQL profiles into the staging table.

The following example populates dba1.my_staging_table with the SQL profile my_profile:

BEGIN
  DBMS_SQLTUNE.pack_stgtab_sqlprof(      
    profile_name         => 'my_profile',   
    staging_table_name   => 'my_staging_table',
    staging_schema_owner => 'dba1' );
END;
/ 
Move the staging table to the database where the SQL profiles will be imported using the mechanism of choice (such as Oracle Data Pump or database link).

On the database where the SQL profiles will be imported, use the UNPACK_STGTAB_SQLPROF procedure to import SQL profiles from the staging table.

The following example shows how to import SQL profiles contained in the staging table:

BEGIN
  DBMS_SQLTUNE.UNPACK_STGTAB_SQLPROF(
      replace  => TRUE,
      staging_table_name => 'my_staging_table');
END;
/

select *
from dba_sql_profiles
where name = 'SYS_SQLPROF_013c4e0be23a0000';

exec dbms_sqltune.create_stgtab_sqlprof(table_name => 'SQL_PROFILES', schema_name => 'TESTER');
exec dbms_sqltune.pack_stgtab_sqlprof(profile_name => 'SYS_SQLPROF_013c4e0be23a0000', staging_table_name => 'SQL_PROFILES', staging_schema_owner => 'TESTER');

--Annotation:
exec dbms_sqltune.create_stgtab_sqlprof(table_name => 'SQL_PROFILES', schema_name => 'GG_EDITORIAL');
exec dbms_sqltune.unpack_stgtab_sqlprof(replace => TRUE, staging_table_name => 'SQL_PROFILES', staging_schema_owner => 'GG_EDITORIAL');


execute dbms_sqltune.accept_sql_profile(task_name => 'TASK_135584', task_owner => 'SYSTEM', replace => TRUE);

