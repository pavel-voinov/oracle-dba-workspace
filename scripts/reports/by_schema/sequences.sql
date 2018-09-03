/*
*/
@reports/reports_header

define schema=&1

column sequence_name format a30 heading "Sequence name"
column min_value format 9999999999990 heading "Min. value"
column max_value format 9999999999990 heading "Max. value"
column increment_by format 9999999999990 heading "Increment By"
column cycle_flag format a10 heading "Cycle"
column order_flag format a10 heading "Order"
column cache_size format 999999990 heading "Cache Size"

SELECT sequence_name, min_value, max_value, increment_by, cycle_flag, order_flag, cache_size
FROM dba_sequences
WHERE sequence_owner = '&schema'
ORDER BY 1
/
