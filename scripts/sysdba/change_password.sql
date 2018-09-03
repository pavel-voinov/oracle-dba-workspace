define p_user=&1
define p_pass=&2

set termout off
column username new_value p_user
SELECT username FROM dba_users WHERE username = upper('&p_user');
set termout on

ALTER USER &p_user IDENTIFIED BY "&p_pass";

