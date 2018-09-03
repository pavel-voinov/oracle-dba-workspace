define rowner=&1
define rname=&2

set termout off
column rowner new_value rowner
column rname new_value rname
SELECT replace(upper('&rowner'), '"') as rowner, replace(upper('&rname'), '"') as rname FROM dual;
set termout on

exec dbms_refresh.make(name => '"&rowner"."&rname"', list => null, next_date => null, interval => null);
