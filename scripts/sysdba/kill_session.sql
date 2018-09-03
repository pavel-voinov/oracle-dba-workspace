/*
*/
set serveroutput on size unlimited verify off timing off feedback off linesize 1024 pagesize 9999 heading off long 32000 autotrace off newpage none

define sess=&1


ALTER SYSTEM KILL SESSION '&1' IMMEDIATE;

