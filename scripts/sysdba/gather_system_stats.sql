set echo on timing on

exec dbms_stats.gather_system_stats;
exec dbms_stats.gather_dictionary_stats;
exec dbms_stats.gather_fixed_objects_stats;
