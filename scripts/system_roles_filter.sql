set termout off feedback off
variable v_sys_roles clob;
variable v_sys_roles_regexp clob;
exec :v_sys_roles := to_clob('AQ_ADMINISTRATOR_ROLE,AQ_USER_ROLE,CONNECT,CTXAPP,DBA,DELETE_CATALOG_ROLE,EXECUTE_CATALOG_ROLE,EXP_FULL_DATABASE,GLOBAL_AQ_USER_ROLE,HS_ADMIN_ROLE,IMP_FULL_DATABASE,JAVA_ADMIN,JAVA_DEPLOY,JAVADEBUGPRIV,JAVAIDPRIV,JAVASYSPRIV,JAVAUSERPRIV,MGMT_USER,OEM_ADVISOR,OEM_MONITOR,RESOURCE,SCHEDULER_ADMIN,SELECT_CATALOG_ROLE,WM_ADMIN_ROLE,XDBADMIN,XDBWEBSERVICES,DATAPUMP_EXP_FULL_DATABASE,DATAPUMP_IMP_FULL_DATABASE,LOGSTDBY_ADMINISTRATOR,RECOVERY_CATALOG_OWNER');
exec :v_sys_roles_regexp := to_clob('^(' || replace(:v_sys_roles, ',', '|') || ')$');

variable v_sys_roles1 clob;
variable v_sys_roles1_regexp clob;
exec :v_sys_roles1 := to_clob('HS_ADMIN_SELECT_ROLE,DBFS_ROLE,GATHER_SYSTEM_STATISTICS,HS_ADMIN_EXECUTE_ROLE,ADM_PARALLEL_EXECUTE_TASK,MAVERICKREAD');
exec :v_sys_roles1_regexp := to_clob('^(' || replace(:v_sys_roles1, ',', '|') || ')$');

set termout on feedback on
