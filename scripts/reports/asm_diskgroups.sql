/*
*/
@@reports.inc
@@db_version

set termout off
column voting_files new_value voting_files
SELECT case
         when to_number('&&db_version') < 11 then
           '''N'''
         else
           'g.voting_files'
       end as voting_files
FROM dual
/
set termout on

column name format a30 heading "Group name"
column state format a10 heading "State"
column type format a10 heading "Type"
column block_size format 999990 heading "Block size,|bytes"
column total_gb format 9999999990 heading "Total size,|Gb"
column offline_disks format 9990 heading "Offline|disks"
column disks format 9990 heading "Number of|disks"
column voting_files format a10 heading "Contains|voting?"
column database_compatibility format a15 heading "Database|compatibility"

break on report
compute sum label "Total" of total_gb on report

SELECT g.name, g.state, g.type, g.block_size, ceil(g.total_mb / 1024) as total_gb,
  (SELECT count(d.disk_number) FROM v$asm_disk d WHERE d.group_number = g.group_number AND mode_status = 'ONLINE') as disks, g.offline_disks,
  &&voting_files as voting_files, g.database_compatibility
FROM v$asm_diskgroup g
ORDER BY g.name
/

clear breaks
clear computes
