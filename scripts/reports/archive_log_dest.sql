/*
*/
@@reports.inc

column idx format 99 heading "#"
column value format a150 word_wrap heading "Value"
column state format a10 heading "State"

SELECT p.idx, p.value, s.value as state
FROM (SELECT to_number(regexp_replace(name, 'log_archive_dest_')) as idx, value
      FROM v$parameter
      WHERE regexp_like(name, '^log_archive_dest_[0-9]+$') AND
        (isdefault = 'FALSE' or ismodified <> 'FALSE')) p, v$parameter s
WHERE s.name = 'log_archive_dest_state_' || p.idx
ORDER BY p.idx
/
