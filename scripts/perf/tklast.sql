store set sqlplus.params replace

set serveroutput on size 1000000 echo off linesize 120 pagesize 20 timing off feedback off verify off

ACCEPT num_files NUMBER DEFAULT 10 PROMPT "Enter number of file to show [10]: " 

column filename heading "Trace filename" format a110

SELECT rownum || '. ' || filename as filename FROM (
  SELECT filename FROM user_available_trace_files
  ORDER BY dt desc
)
WHERE rownum <= &num_files
/

set term off

column filename new_val default_filename

SELECT filename
FROM (
  SELECT filename FROM user_available_trace_files
  ORDER BY dt desc
)
WHERE rownum = 1
/

set term on

PROMPT 
ACCEPT f DEFAULT &default_filename PROMPT "Enter trace filename to analyze and show [&default_filename]: "
ACCEPT sort_options DEFAULT 'fchela' PROMPT "Enter sort options for tkprof [fchela]: "
PROMPT

exec trace_files.trace_file_contents('&f');

set termout off
set heading off feedback off embedded on linesize 4000 trimspool on verify off
spool &f
select text from trace_files.trace_files_text order by id;
spool off
@sqlplus.params
set termout on
host rm -f /tmp/sqlplus.params

host tkprof &f &f..out sys=no aggregate=yes waits=yes sort=&sort_options
host less &f..out
host rm -i &f &f..out

