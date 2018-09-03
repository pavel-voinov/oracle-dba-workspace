set serveroutput on size unlimited linesize 250 trimspool on

declare
  obj_id number;
  l_table varchar2(30) := upper('&1');
  l_task varchar2(512);
begin
  l_task := 'Manual_' || l_table;
  dbms_advisor.create_task (advisor_name => 'Segment Advisor', task_name => l_task);

  dbms_advisor.create_object (
    task_name        => l_task,
    object_type      => 'TABLE',
    attr1            => sys_context('USERENV', 'CURRENT_SCHEMA'),
    attr2            => l_table,
    attr3            => NULL,
    attr4            => NULL,
    attr5            => NULL,
    object_id        => obj_id);

  dbms_advisor.set_task_parameter(
    task_name        => l_task,
    parameter        => 'recommend_all',
    value            => 'TRUE');

  dbms_advisor.execute_task(l_task);
end;
/
BREAK ON REPORT
COMPUTE SUM LABEL TOTAL OF alloc_mb ON REPORT
COMPUTE SUM LABEL TOTAL OF used_mb ON REPORT
COMPUTE SUM LABEL TOTAL OF reclaim_mb ON REPORT

column segment_name format a30
column recommedations format a100 word_wrap

SELECT segment_name,
       round(allocated_space/1024/1024,1) alloc_mb,
       round( used_space/1024/1024, 1 ) used_mb,
       round( reclaimable_space/1024/1024) reclaim_mb,
       round(reclaimable_space/allocated_space*100,0) pctsave,
       recommendations
FROM TABLE(dbms_space.asa_recommendations())
WHERE segment_owner = sys_context('USERENV', 'CURRENT_SCHEMA')
ORDER BY 4 DESC
/
exec dbms_advisor.delete_task('Manual_' || upper('&1'));
