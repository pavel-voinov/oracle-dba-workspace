/*
*/
@@reports.inc

column snapshot_interval format 9999990 heading "Snapshot Interval, mins"
column retention_interval format 9999990 heading "Retention Interval, days"

SELECT extract(day from snap_interval) * 24 * 60 + extract(hour from snap_interval) * 60 + extract(minute from snap_interval) as snapshot_interval,
  ceil(extract(day from retention) + extract(hour from retention) / 24 + extract(minute from retention) / 24 / 60) as retention_interval
FROM dba_hist_wr_control
/
