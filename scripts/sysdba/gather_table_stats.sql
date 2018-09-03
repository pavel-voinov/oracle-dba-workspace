/*
*/
set serveroutput on size unlimited timing off verify off

set termout off
column p_schema new_value p_schema
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as p_schema FROM dual;
set termout on

define p_schema=&1
define p_table_name=&2
define p_method_opt='FOR ALL COLUMNS SIZE AUTO'
--SKEWONLY

PROMPT Gather statistics for table(s) in '&p_schema'

begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM dba_tables
            WHERE regexp_like(owner, '^(' || replace('&p_schema', '$' , '\$') || ')$', 'i')
              AND table_name like upper('&p_table_name')
              AND temporary = 'N'
              AND iot_name is null
            MINUS
            SELECT owner, table_name
            FROM dba_external_tables)
  loop
    dbms_output.put(t.owner || '.' || t.table_name);
    begin
      dbms_stats.gather_table_stats(
        ownname => t.owner,
        tabname => t.table_name,
        estimate_percent => dbms_stats.auto_sample_size,
        method_opt => '&&p_method_opt', 
        cascade => true, 
        degree => dbms_stats.auto_degree, 
        force => true);
      dbms_output.put_line(' - OK');
    exception when others then
      dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
