drop public synonym plan_table;
create public synonym plan_table for &1..plan_table;
grant all on &1..plan_table to public;
