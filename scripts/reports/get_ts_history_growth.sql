/*
*/
@@reports.inc

define ts=&1

SELECT to_char(sp.begin_interval_time, 'YYYY-MM-DD') days,
  ts.tsname, max(round((tsu.tablespace_size * dt.block_size) / power(2, 20), 2)) as current_size_mb,
  max(round((tsu.tablespace_usedsize * dt.block_size ) / power(2, 20), 2)) as used_size_mb
FROM dba_hist_tbspc_space_usage tsu, dba_hist_tablespace_stat ts, dba_hist_snapshot sp, dba_tablespaces dt
wHERE tsu.tablespace_id= ts.ts#
  AND tsu.snap_id = sp.snap_id
  AND ts.tsname = dt.tablespace_name
  AND ts.tsname = upper('&ts')
GROUP BY to_char(sp.begin_interval_time, 'YYYY-MM-DD'), ts.tsname
ORDER BY ts.tsname, days DESC
/
