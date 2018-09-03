set serveroutput on size unlimited
@system_users_filter.sql

begin
  dbms_output.enable(null);
  for u in (SELECT username, default_tablespace as tablespace_name FROM dba_users WHERE not regexp_like(username, :v_sys_users_regexp)
            MINUS
            SELECT username, tablespace_name FROM dba_ts_quotas WHERE max_bytes = -1)
  loop
    execute immediate 'ALTER USER "' || u.username || '" QUOTA UNLIMITED ON "' || u.tablespace_name || '"';
  end loop;      
end;
/
