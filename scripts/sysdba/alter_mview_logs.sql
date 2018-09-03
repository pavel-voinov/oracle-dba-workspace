set serveroutput on size unlimited

define p_schema=&1
define p_tables=&2

declare

  procedure alter_mview_log (
    p_table in varchar2)
  is
    l_SQL        varchar2(32000);
  begin
    l_SQL := 'ALTER MATERIALIZED VIEW LOG FORCE ON "' || upper('&p_schema') || '"."' || upper(p_table) || '" ADD PRIMARY KEY, ROWID, SEQUENCE, INCLUDING NEW VALUES';

    begin
      dbms_output.put('Alter mview log on "' || upper('&p_schema') || '"."' || upper(p_table) || '" - ');
      execute immediate l_SQL;
      dbms_output.put_line('OK');
    exception when others then
      dbms_output.put_line('FAILED: ' || SQLERRM);
    end;
  end;

begin
  dbms_output.enable(null);

  for t in (SELECT distinct master as table_name
            FROM dba_mview_logs
            WHERE log_owner = upper('&p_schema')
              AND master like upper('&p_tables')
              AND (rowids = 'NO' or include_new_values = 'NO' or sequence = 'NO'))
  loop
    alter_mview_log(t.table_name);
  end loop;
end;
/
