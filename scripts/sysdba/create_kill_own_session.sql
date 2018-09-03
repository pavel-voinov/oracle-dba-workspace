-- Author: Xavi Morera
-- Date: 18-MAR-2015
-- 
-- Desc: To be created on a schema with DBA privileges
-- Grant execute priv on it to the schema that needs the priv to terminate own sessions
-- 
set serveroutput on size unlimited

create or replace PROCEDURE kill_user_session(
    n_sid    IN NUMBER,
    n_serial IN NUMBER,
    n_inst_id IN NUMBER)
AS
BEGIN
  DECLARE
    v_myuser   VARCHAR2(30) DEFAULT '';
    v_killuser VARCHAR2(30) DEFAULT '';
    
  BEGIN
    SELECT sys_context('USERENV','SESSION_USER') 
    INTO v_myuser 
    FROM dual;
    
    SELECT username
    INTO v_killuser
    FROM gv$session
    WHERE sid    =n_sid
    AND serial#  =n_serial
    AND inst_id  =n_inst_id
    AND status not in ('KILLED');
    
    IF ( v_killuser=v_myuser) THEN
      EXECUTE immediate('ALTER SYSTEM KILL SESSION ''' || n_sid || ',' || n_serial || ',@' || n_inst_id || ''' IMMEDIATE;');
    ELSE
      raise_application_error(-20000, 'Username mismatch: You can not kill the session of another schema!');
    END IF;
    
  EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20001,'An error was encountered - ' || sqlerrm);
  END;
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20002,'An error was encountered - '  || sqlerrm);  
END kill_user_session;
/