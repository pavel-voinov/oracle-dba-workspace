column metric_name format a36
column metric_unit format a17
column minval format 9999999990.00
column maxval format 9999999990.00
column average format 9999999990.00
column standard_deviation format 9999999990.00

PROMPT Reads per second:
SELECT inst_id, begin_time, end_time, intsize_csec, metric_name, num_interval, minval, maxval, average, standard_deviation
FROM gv$sysmetric_summary
WHERE metric_unit = 'Reads Per Second'
ORDER BY metric_name, inst_id, begin_time
/
