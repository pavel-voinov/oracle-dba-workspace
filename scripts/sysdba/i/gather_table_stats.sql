/*
*/
set serveroutput on size unlimited timing off verify off

set termout off
column p_schema new_value p_schema
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as p_schema FROM dual;
set termout on

ACCEPT p_schema DEFAULT '&p_schema' PROMPT "Schema name. [&p_schema]: "
ACCEPT table_name DEFAULT '.*' PROMPT "Table name [all, if not specified]: "
ACCEPT method_opt DEFAULT 'FOR ALL COLUMNS SIZE AUTO' PROMPT "Gather method options [FOR ALL COLUMNS SIZE AUTO]: "
--SKEWONLY

PROMPT Gather statistics for table(s) in '&p_schema'

begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM dba_tables
            WHERE regexp_like(owner, '^(&p_schema.)$', 'i')
              AND regexp_like(table_name, '^(&table_name.)$', 'i')
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
        method_opt => '&&method_opt', 
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
