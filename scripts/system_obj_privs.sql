set termout off feedback off
variable v_sys_objprivs varchar2(4000);
variable v_sys_objprivs_regexp varchar2(4000);
exec :v_sys_objprivs := 'V_$SESSION,GV_$SESSION,V_$SESSION_LONGOPS,GV_$SESSION_LONGOPS,V_$INSTANCE,GV_$INSTANCE,DBMS_REFRESH,DBMS_SNAPSHOT,DBMS_FILE_TRANSFER,DBMS_LOCK,DBMS_REFRESH,V_$DATABASE,GV_$DATABASE,THOR_IMPORT,GV_$SQL,GV_$SQL_PLAN,V_$SQL,V_$SQL_PLAN';
exec :v_sys_objprivs_regexp := '^(' || replace(replace(:v_sys_objprivs, ',', '|'), '$', '\$') || ')$';
set termout on feedback on

