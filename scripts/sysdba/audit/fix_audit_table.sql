set serveroutput on size unlimited timing on

select count(1), min(timestamp), max(timestamp) from dba_audit_trail;
declare
  l_cnt number;
begin
  select count(*) into l_cnt from dba_audit_mgmt_last_arch_ts;

  if l_cnt = 0 then
    dbms_audit_mgmt.set_last_archive_timestamp(audit_trail_type => dbms_audit_mgmt.AUDIT_TRAIL_AUD_STD, last_archive_time => systimestamp - 5);
  end if;

  dbms_audit_mgmt.clean_audit_trail(audit_trail_type => dbms_audit_mgmt.AUDIT_TRAIL_AUD_STD);
end;
/
exec dbms_scheduler.run_job('SYS.PURGE_AUDIT');
select * from dba_audit_mgmt_last_arch_ts;
select count(1), min(timestamp), max(timestamp) from dba_audit_trail;
-- @sysdba/maxshrink SYSAUX

exit
