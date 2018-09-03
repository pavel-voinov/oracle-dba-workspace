/*
*/
@@reports.inc

column directory_name format a30
column directory_path format a140 word_wrap

SELECT directory_name, directory_path
FROM dba_directories
ORDER BY 1
/
