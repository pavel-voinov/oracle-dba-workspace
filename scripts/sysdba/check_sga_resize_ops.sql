/*

Script to check health of SGA resize operations frequence (MetaLink Doc ID: 742599.1)
*/
@reports/reports_header

column component format a25
column oper_type format a25
column final_size format 99,999,999,999
column start_time format a25

SELECT inst_id, component, oper_type, final_size, start_time
FROM gv$sga_resize_ops
ORDER BY inst_id, component, start_time
/

SELECT inst_id, component, oper_type, count(*) as cnt
FROM gv$sga_resize_ops
GROUP BY inst_id, component, oper_type
ORDER BY inst_id, component, cnt desc
/
