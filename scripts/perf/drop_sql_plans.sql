set serveroutput on size unlimited

define sql_id=&1

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

/*
SELECT * FROM gv$sql WHERE sql_id = '7kgnz4tt2mw4x';
SELECT * FROM dba_sql_plan_baselines WHERE plan_name = 'SQL_PLAN_1fg49tapv6uyyf476c844';

SELECT DISTINCT s.inst_id, p.sql_handle, p.plan_name
            FROM dba_sql_plan_baselines p, gv$sql s
            WHERE p.plan_name = s.sql_plan_baseline AND s.sql_id = '7kgnz4tt2mw4x';

declare
  l_num number;
begin
  dbms_output.enable(null);
  l_num := dbms_spm.load_plans_from_cursor_cache (sql_id => '7kgnz4tt2mw4x');
  dbms_output.put_line(l_num);
end;
/
*/
