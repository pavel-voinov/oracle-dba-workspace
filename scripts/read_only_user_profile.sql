-- Script to create resource limit profile for Read-Only users

CREATE PROFILE  RO_USER  LIMIT
CPU_PER_SESSION                 60000 
LOGICAL_READS_PER_SESSION   2000 
CONNECT_TIME              43200 
CPU_PER_CALL              720000 
FAILED_LOGIN_ATTEMPTS       UNLIMITED
PASSWORD_LIFE_TIME              UNLIMITED
PASSWORD_REUSE_TIME             UNLIMITED
PASSWORD_VERIFY_FUNCTION        NULL
PASSWORD_LOCK_TIME              1
PASSWORD_GRACE_TIME             7
/

declare
  v_username varchar2(20);

begin
  select username
    into v_username
    from dba_users
   where username in
         ('EDITORIAL_RO', 'CORTELLIS_RO', 'STAGING_RO', 'ESTAGING_RO');

  if v_username = 'EDITORIAL_RO' then
    execute immediate 'alter user EDITORIAL_RO profile RO_USER';
    elsif v_username = 'STAGING_RO' then execute immediate 'alter user STAGING_RO profile RO_USER';
    elsif v_username = 'ESTAGING_RO' then execute immediate 'alter user ESTAGING_RO profile RO_USER';
    elsif v_username = 'CORTELLIS_RO' then execute immediate 'alter user CORTELLIS_RO profile RO_USER';
  else
    DBMS_OUTPUT.PUT_LINE('Read-only user does not exist');
    end if;
  end;
/

