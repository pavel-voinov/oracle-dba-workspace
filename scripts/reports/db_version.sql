/*

Script to get current database version
*/
set termout off echo off feedback off verify off timing off heading off
variable full_version varchar2(255)
variable version varchar2(255)
variable compatibility varchar2(255)
begin
  dbms_utility.db_version(:full_version, :compatibility);
  :version := replace(regexp_substr(:full_version, '^[0-9]*?\.'), '.');
end;
/
column db_version new_value db_version
column db_full_version new_value db_full_version

SELECT :version as db_version, :full_version as db_full_version
FROM dual
/
set termout on feedback on heading on
