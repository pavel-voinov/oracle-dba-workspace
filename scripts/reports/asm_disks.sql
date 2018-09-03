/*
*/
@@reports.inc
@@db_version

set termout off
column voting_file new_value voting_file
SELECT case
         when to_number('&&db_version') < 11 then
           '''?'''
         else
           'd.voting_file'
       end as voting_file
FROM dual
/
set termout on

column group_name format a15 heading "Group name"
column name format a20 heading "Disk name"
column label format a30 heading "Disk label"
column path format a40 heading "Disk path"
column state format a10 heading "Group state"
column mode_status format a10 heading "Mode|status"
column mount_status format a10 heading "Mount|status"
column type format a10 heading "Type"
column total_gb format 9999999990 heading "Total size,|Gb"
column voting_file format a10 heading "Contains|voting?"

break on group_name
break on report
compute sum label "Total, Gb" of total_gb on report
compute sum label "Total, Gb" of total_gb on group_name

SELECT g.name as group_name, g.state, d.name, d.label, d.path, ceil(d.total_mb / 1024) as total_gb, d.mode_status, d.mount_status, &&voting_file as voting_file
FROM v$asm_diskgroup g, v$asm_disk d
WHERE d.group_number = g.group_number
ORDER BY g.name, d.disk_number
/

clear breaks
clear computes
