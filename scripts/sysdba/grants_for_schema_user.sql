set serveroutput on size unlimited echo off verify off

define schema=&1

GRANT create table TO &schema;
GRANT create view TO &schema;
GRANT create synonym TO &schema;
GRANT create sequence TO &schema;
GRANT create procedure TO &schema;
GRANT create trigger TO &schema;
GRANT create type TO &schema;
GRANT create materialized view TO &schema;
GRANT alter any materialized view TO &schema;
GRANT alter session TO &schema;
--GRANT create database link TO &schema;
GRANT create job TO &schema;
GRANT select ON sys.v_$session TO &schema;
GRANT select ON sys.gv_$session TO &schema;
GRANT select ON sys.v_$session_longops TO &schema;
GRANT select ON sys.gv_$session_longops TO &schema;
GRANT select ON sys.v_$instance TO &schema;
GRANT select ON sys.v_$database TO &schema;
