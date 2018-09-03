/*
*/
@@reports.inc

column dbtimezone format a30 heading "DB Time Zone"
column filename format a20 heading "Time Zone file"
column version format 99999999999990D9999 heading "Version"

SELECT dbtimezone FROM dual
/
SELECT * FROM v$timezone_file ORDER BY filename
/
