/*
*/
set serveroutput on size unlimited echo off scan on verify off
@@system_users_filter.sql

set termout off
column schema new_value schema
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as schema
FROM dual;
set termout on

PROMPT Current schema is "&schema"

PROMPT Objects count before:
SELECT object_type, count(*) as cnt
FROM user_objects
WHERE not regexp_like(sys_context('USERENV', 'CURRENT_SCHEMA'), :v_sys_users_regexp)
GROUP BY object_type ORDER BY 1
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT object_name, object_type
            FROM user_objects
            WHERE object_type in ('PROCEDURE', 'FUNCTION', 'TYPE', 'PACKAGE', 'TRIGGER', 'MATERIALIZED VIEW', 'VIEW', 'SYNONYM', 'SEQUENCE', 'TABLE', 'DATABASE LINK','JAVA SOURCE','PACKAGE BODY')
              AND secondary = 'N'
              AND not regexp_like(sys_context('USERENV', 'CURRENT_SCHEMA'), :v_sys_users_regexp)
            ORDER BY decode(object_type, 'PROCEDURE', 1, 'FUNCTION', 2, 'TYPE', 3, 'PACKAGE', 4, 'TRIGGER', 5,
              'MATERIALIZED VIEW', 6, 'VIEW', 7, 'SYNONYM', 8, 'SEQUENCE', 9, 'JAVA SOURCE',10,'PACKAGE BODY',11))
  loop
    l_SQL := 'DROP ' || t.object_type || ' "' || t.object_name || '"';
    if t.object_type = 'TABLE' then
      l_SQL := l_SQL || ' CASCADE CONSTRAINTS PURGE';
    end if;
    begin
      dbms_output.put(l_SQL);
      execute immediate l_SQL;
      dbms_output.put_line(' - OK');
    exception when others then
      dbms_output.put_line(':' || SQLERRM);
    end;
  end loop;
end;
/
declare
  l_SQL varchar2(32000);
begin
for t in (SELECT object_name, object_type
           FROM user_objects
           WHERE object_type='JOB'
             AND secondary = 'N'
             AND not regexp_like(sys_context('USERENV', 'CURRENT_SCHEMA'), :v_sys_users_regexp)
           ORDER BY decode(object_type, 'JOB', 1))
 loop
   begin
     dbms_output.put(l_SQL);
     dbms_scheduler.drop_job(job_name=>t.object_name);
     dbms_output.put_line(' - OK');
   exception when others then
     dbms_output.put_line(':' || SQLERRM);
   end;
 end loop;
end;
/
begin
  dbms_output.enable(null);
  for t in (SELECT rname as group_name
            FROM user_refresh
            WHERE not regexp_like(sys_context('USERENV', 'CURRENT_SCHEMA'), :v_sys_users_regexp))
  loop
    begin
      dbms_output.put('Drop refresh group: ' || t.group_name);
      dbms_refresh.destroy('"' || t.group_name || '"');
      dbms_output.put_line(' - OK');
    exception when others then
      dbms_output.put_line(': ' || SQLERRM);
    end;
  end loop;
end;
/
PROMPT Objects count after:
SELECT object_type, object_name
FROM user_objects
WHERE not regexp_like(sys_context('USERENV', 'CURRENT_SCHEMA'), :v_sys_users_regexp)
ORDER BY 1, 2
/

undefine schema
