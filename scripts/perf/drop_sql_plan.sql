set serveroutput on size unlimited

define sql_id=&1
define plan_hash=&2

declare
  l_sql_plan      varchar2(255);
  l_inst_id       integer;
  l_plans_dropped pls_integer;
begin
  dbms_output.enable(null);
  for h in (SELECT DISTINCT p.sql_handle, p.plan_name
            FROM dba_sql_plan_baselines p, gv$sql s
            WHERE s.sql_id = '&sql_id' AND p.plan_name = s.sql_plan_baseline
              AND s.sql_plan_baseline is not null)
  loop
    l_plans_dropped := dbms_spm.drop_sql_plan_baseline(sql_handle => h.sql_handle);
    dbms_output.put_line(h.plan_name || ': ' || l_plans_dropped);
  end loop;
  commit;
end;
/
