/*

This script is to create/alter network ACLs
*/
set serveroutput on size 1000000 linesize 1024 pagesize 9999 trimspool on newpage none heading off feedback off timing off

define acl_name=&1
define principal=&2
-- default is *
define host=&3
define acl_descr=&4

begin
  dbms_network_acl_admin.create_acl(acl => '&acl_name', description => '&acl_descr', principal => '&principal', is_grant => true, privilege => 'connect');
end;
/
begin
  dbms_network_acl_admin.assign_acl(acl => '&acl_name', host => '*', lower_port => null, upper_port => null);
end;
/
begin
  dbms_network_acl_admin.add_privilege(acl => '&acl_name', principal => '&principal', is_grant => true, privilege => 'resolve');
end;
/
