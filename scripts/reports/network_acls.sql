/*
*/
@@reports.inc
@@db_version

set termout off
column query new_value query
SELECT case
         when to_number('&&db_version') < 11 then
           'nothing'
         else
           'network_acls_query'
       end as query
FROM dual
/
set termout on

@@&&query
