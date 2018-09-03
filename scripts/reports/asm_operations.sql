/*
*/
@@reports.inc
@@db_version

set termout off
column err_code new_value err_code
SELECT case
         when to_number('&&db_version') < 11 then
           'null'
         else
           'd.error_code'
       end as err_code
FROM dual
/
set termout on

column group_name format a15 heading "Group name"
column inst_id format 9999990 heading "Instance"
column operation format a30 heading "Operation"
column state format a10 heading "State"
column power format a10 heading "Power|set/actual"
column est_minutes format 9999990 heading "ETA, min"
column error_code format a44 heading "Error code"

SELECT d.inst_id, g.name as group_name, d.operation, d.state, d.power || '/' || d.actual as power, d.est_minutes, &&err_code as error_code
FROM gv$asm_operation d, v$asm_diskgroup g
WHERE d.group_number = g.group_number(+)
ORDER BY 1, 2
/
