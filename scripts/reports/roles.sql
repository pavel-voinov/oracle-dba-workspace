/*
*/
@@reports.inc
@@db_version

set termout off
column role format a30 heading "Role name"
column password_required format a22 heading "Is password required"
column authentication_type format a25 heading "Authentication type"
column authentication_type new_value authentication_type

SELECT case
         when to_number('&&db_version') < 11 then
           ''
         else
           ', authentication_type'
       end as authentication_type
FROM dual
/
set termout on

SELECT role, password_required&&authentication_type 
FROM dba_roles
ORDER BY 1
/

undefine authentication_type
