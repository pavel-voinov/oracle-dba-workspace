
ACCEPT task_name PROMPT "Enter SQL Tuning task name: "
ACCEPT profile_name PROMPT "Enter SQL Profile name: "

DECLARE
  l_sql_tune_task_id  VARCHAR2(200);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.accept_sql_profile (
                          task_name => '&task_name',
                          name      => '&profile_name',
                          force_match  => TRUE,
                          profile_type => DBMS_SQLTUNE.PX_PROFILE);
END;
/
