/*

Several parameters changes on RDBMS, workarounds, etc.
*/
set echo on

ALTER DATABASE FORCE LOGGING;

ALTER SYSTEM SET parallel_force_local=TRUE SCOPE=BOTH SID='*';
ALTER SYSTEM SET deferred_segment_creation=FALSE SCOPE=BOTH SID='*';
ALTER SYSTEM SET db_file_multiblock_read_count=128 SCOPE=BOTH SID='*';
ALTER SYSTEM SET job_queue_processes=1000 SCOPE=BOTH SID='*';
ALTER SYSTEM SET statistics_level=ALL SCOPE=BOTH SID='*';
-- Instance(s) restart is required
ALTER SYSTEM SET streams_pool_size=4096M SCOPE=SPFILE SID='*';
ALTER SYSTEM SET recyclebin=OFF SCOPE=SPFILE SID='*';
ALTER SYSTEM SET open_links=16 SCOPE=SPFILE SID='*';
ALTER SYSTEM SET open_links_per_instance=16 SCOPE=SPFILE SID='*';
ALTER SYSTEM SET open_cursors=1000 SCOPE=BOTH SID='*';
ALTER SYSTEM SET sga_max_size=80G SCOPE=SPFILE SID='*';
ALTER SYSTEM SET sga_target=80G SCOPE=SPFILE SID='*';
ALTER SYSTEM SET pga_aggregate_target=20G SCOPE=SPFILE SID='*';
ALTER SYSTEM RESET db_cache_size SCOPE=SPFILE SID='*';
ALTER SYSTEM SET audit_sys_operations=TRUE SCOPE=SPFILE SID='*';
ALTER SYSTEM SET audit_trail='DB' SCOPE=SPFILE SID='*';
