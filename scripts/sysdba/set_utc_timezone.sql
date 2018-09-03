exec dbms_scheduler.set_scheduler_attribute('DEFAULT_TIMEZONE', 'UTC');
commit;

--select * from dba_scheduler_global_attribute;

