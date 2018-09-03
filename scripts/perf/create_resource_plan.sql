DECLARE
  spfileValue VARCHAR2(1000);
  execText VARCHAR2(1000);
  scopeValue VARCHAR2(30) := 'MEMORY';
  planName VARCHAR2(100) := 'BUNDLE_PLAN';
BEGIN
  dbms_resource_manager.clear_pending_area();
  dbms_resource_manager.create_pending_area();
  dbms_resource_manager.create_plan(plan => planName, comment => ?, max_iops => ?, max_mbps => ? );
  dbms_resource_manager.create_plan_directive(
    plan => ?,
    group_or_subplan => ?,
    comment => ?,
    mgmt_p1 => ?, mgmt_p2 => ?, mgmt_p3 => ?, mgmt_p4 => ?,
    mgmt_p5 => ?, mgmt_p6 => ?, mgmt_p7 => ?, mgmt_p8 => ? ,
    parallel_degree_limit_p1 => ? ,
    switch_io_reqs => ? ,
   switch_io_megabytes => ?
,
    active_sess_pool_p1 => ?,
    queueing_p1 => ?,
    switch_group => ?,
    switch_time => ?,
    switch_estimate => case ? when 'false' then false when 'true' then true else false end,
    max_est_exec_time => ?,
    undo_pool => ? ,
    max_idle_time => ?,
    max_idle_blocker_time => ?,
    switch_for_call => case ? when 'false' then false when 'true' then true else false end

);
dbms_resource_manager.create_plan_directive(
    plan => ?,
    group_or_subplan => ?,
    comment => ?,
    mgmt_p1 => ?, mgmt_p2 => ?, mgmt_p3 => ?, mgmt_p4 => ?,
    mgmt_p5 => ?, mgmt_p6 => ?, mgmt_p7 => ?, mgmt_p8 => ? ,
    parallel_degree_limit_p1 => ? ,
    switch_io_reqs => ? ,
   switch_io_megabytes => ?
,
    active_sess_pool_p1 => ?,
    queueing_p1 => ?,
    switch_group => ?,
    switch_time => ?,
    switch_estimate => case ? when 'false' then false when 'true' then true else false end,
    max_est_exec_time => ?,
    undo_pool => ? ,
    max_idle_time => ?,
    max_idle_blocker_time => ?,
    switch_for_call => case ? when 'false' then false when 'true' then true else false end

);
dbms_resource_manager.create_plan_directive(
    plan => ?,
    group_or_subplan => ?,
    comment => ?,
    mgmt_p1 => ?, mgmt_p2 => ?, mgmt_p3 => ?, mgmt_p4 => ?,
    mgmt_p5 => ?, mgmt_p6 => ?, mgmt_p7 => ?, mgmt_p8 => ? ,
    parallel_degree_limit_p1 => ? ,
    switch_io_reqs => ? ,
   switch_io_megabytes => ?
,
    active_sess_pool_p1 => ?,
    queueing_p1 => ?,
    switch_group => ?,
    switch_time => ?,
    switch_estimate => case ? when 'false' then false when 'true' then true else false end,
    max_est_exec_time => ?,
    undo_pool => ? ,
    max_idle_time => ?,
    max_idle_blocker_time => ?,
    switch_for_call => case ? when 'false' then false when 'true' then true else false end

);
dbms_resource_manager.submit_pending_area();
END;
/
