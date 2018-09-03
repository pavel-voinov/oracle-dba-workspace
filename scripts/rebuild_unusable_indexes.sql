set serveroutput on size 1000000 echo off timing off linesize 100

PROMPT Rebuilding unusable indexes in current schema

column cnt heading "Count of indexes in UNUSABLE state"
PROMPT Before:
SELECT count(*) as cnt FROM all_indexes WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA') AND status = 'UNUSABLE';

set timing on

begin
  dbms_output.enable(null);
  for t in (SELECT '"' || owner || '"."' || index_name || '"' as index_name
            FROM all_indexes
            WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND status = 'UNUSABLE')
  loop
    begin
      execute immediate 'ALTER INDEX ' || t.index_name || ' REBUILD';
    exception when others then
      dbms_output.put_line(t.index_name || ': ' || SQLERRM);
    end;
  end loop;
end;
/

set timing off

PROMPT After:
SELECT count(*) as cnt FROM all_indexes WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA') AND status = 'UNUSABLE';
