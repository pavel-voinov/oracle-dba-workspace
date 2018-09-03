set feedback off echo off timing on

column instance_name format a10 heading "Instance"
column host_name format a20 heading "Host name"
column service_name format a30 heading "Service name"

SELECT INSTANCE_NAME, HOST_NAME, sys_context('USERENV', 'SERVICE_NAME') as service_name FROM v$instance;
exit
