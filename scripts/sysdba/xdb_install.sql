/*

Master Note for Oracle XML Database (XDB) Install / Deinstall (Doc ID 1292089.1)
*/
spool xdb_install.log
set echo on
connect / as sysdba
--shutdown immediate
--startup
@?/rdbms/admin/catqm.sql change_on_install SYSAUX TEMP YES
@?/rdbms/admin/utlrp.sql
spool off
spool xdb_status.txt

set echo on;
connect / as sysdba
set pagesize 1000
col comp_name format a36
col version format a12
col status format a8
col owner format a12
col object_name format a35
col name format a25

-- Check status of XDB

select comp_name, version, status
from dba_registry
where comp_id = 'XDB';

-- Check for invalid objects

select owner, object_name, object_type, status
from dba_objects
where status = 'INVALID'
and owner in ('SYS', 'XDB');

spool off;
