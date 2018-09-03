/*
*/
set serveroutput on size unlimited timing off verify off

set termout off
column p_schema new_value p_schema
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as p_schema FROM dual;
set termout on

define p_schema=&1
define p_table_name=&2
define p_date=&3

PROMPT Restore statistics for table(s) in '&p_schema' to state as of &p_date

begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM dba_tables
            WHERE owner like upper('&p_schema')
              AND table_name like upper('&p_table_name')
              AND temporary = 'N'
              AND iot_name is null
            MINUS
            SELECT owner, table_name
            FROM dba_external_tables
            WHERE owner like upper('&p_schema'))
  loop
    dbms_output.put(t.owner || '.' || t.table_name || ': ');
    begin
      dbms_stats.restore_table_stats(
        ownname => t.owner,
        tabname => t.table_name,
        as_of_timestamp => to_date('&p_date', 'DD.MM.YYYY'),
        no_invalidate => false,
        force => true);
      dbms_output.put_line('OK');
    exception when others then
      dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
