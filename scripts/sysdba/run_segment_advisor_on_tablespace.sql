set serveroutput on size unlimited linesize 250 trimspool on echo on

variable p_task_id number;
variable p_tablespace varchar2(30);
variable p_task_name varchar2(512);

begin
  :p_tablespace := upper('&1');
  :p_task_name := 'TBS_' || upper('&1');
end;
/

PROMPT :p_tablespace
PROMPT :p_task_name

declare
  obj_id number;
begin
  dbms_advisor.create_task (
    advisor_name => 'Segment Advisor',
    task_id => :p_task_id,
    task_name => :p_task_name,
    task_desc => 'Analyse segments in tablespace "' || :p_tablespace || '"');

  dbms_advisor.create_object (
    task_name        => :p_task_name,
    object_type      => 'TABLESPACE',
    attr1            => :p_tablespace,
    attr2            => null,
    attr3            => null,
    attr4            => null,
    attr5            => null,
    object_id        => obj_id);

  dbms_advisor.set_task_parameter(
    task_name        => :p_task_name,
    parameter        => 'recommend_all',
    value            => 'TRUE');

  dbms_advisor.execute_task(:p_task_name);
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
       round(used_space/1024/1024, 1 ) used_mb,
       round(reclaimable_space/1024/1024) reclaim_mb,
       round(reclaimable_space/allocated_space*100,0) pctsave,
       recommendations
FROM TABLE(dbms_space.asa_recommendations())
WHERE task_id = :p_task_id and tablespace_name = :p_tablespace
ORDER BY 4 DESC
/
exec dbms_advisor.delete_task(:p_task_name);
