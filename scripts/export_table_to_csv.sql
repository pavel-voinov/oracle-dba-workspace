-- Execute in SQLcli only
ALTER SESSION SET nls_date_format='YYYY-MM-DD HH24:MI:SS';
set heading off feedback off pagesize 9999 trimspool on
set null 'NULL'
define tab=&1
column scn format 9999999999999999999990
column scn new_value scn
spool &tab..txt
select min(current_scn) as scn from gv$database;
spool off
set sqlformat csv
spool &tab..csv
select * from &tab. as of scn &scn;
spool off

