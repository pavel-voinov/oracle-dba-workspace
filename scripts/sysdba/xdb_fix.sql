-- Make XDB Dummy views
start ?/rdbms/admin/catxdbdv.sql

-- update Data Pump related objects and KU$_ views

start ?/rdbms/admin/dbmsmeta.sql
start ?/rdbms/admin/dbmsmeti.sql
start ?/rdbms/admin/dbmsmetu.sql
start ?/rdbms/admin/dbmsmetb.sql
start ?/rdbms/admin/dbmsmetd.sql
start ?/rdbms/admin/dbmsmet2.sql
start ?/rdbms/admin/catmeta.sql
start ?/rdbms/admin/prvtmeta.plb
start ?/rdbms/admin/prvtmeti.plb
start ?/rdbms/admin/prvtmetu.plb
start ?/rdbms/admin/prvtmetb.plb
start ?/rdbms/admin/prvtmetd.plb
start ?/rdbms/admin/prvtmet2.plb
start ?/rdbms/admin/catmet2.sql

REM Check to verify that all components are valid
select COMP_ID, COMP_NAME, VERSION, STATUS from dba_registry;

