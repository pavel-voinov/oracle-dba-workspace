begin
  dbms_resource_manager.clear_pending_area();
  dbms_resource_manager.create_pending_area();
  dbms_resource_manager.create_consumer_group(consumer_group => 'BUNDLE_GROUP', comment => 'GeneGo Bundle consumer group' , cpu_mth => ?);
  dbms_resource_manager.submit_pending_area();
  begin
    dbms_resource_manager_privs.grant_switch_consumer_group(consumer_group => 'BUNDLE_GROUP', schema => 'BUNDLE', admin_option => case ? when 'false' then false when 'true' then true else false end);
    dbms_resource_manager_privs.grant_switch_consumer_group(?,?,case ? when 'false' then false when 'true' then true else false end);
  end;
end;
/
