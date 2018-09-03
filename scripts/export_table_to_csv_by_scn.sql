ALTER SESSION SET nls_date_format='YYYY-MM-DD HH24:MI:SS';
set heading off feedback off pagesize 9999 trimspool on
set null 'NULL'
set sqlformat csv
define tab=&1
define scn=&2
spool &tab..csv
select * from &tab. as of scn &scn;
spool off

