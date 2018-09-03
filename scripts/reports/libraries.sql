/*
*/
@@reports.inc

column owner format a30 heading "Owner"
column library_name format a30 heading "Library name"
column file_spec format a90 heading "File specification"
column dynamic format a8 heading "Dynamic"
column status format a8 heading "Status"

SELECT owner, library_name, file_spec, dynamic, status
FROM dba_libraries
ORDER BY owner, library_name
/
