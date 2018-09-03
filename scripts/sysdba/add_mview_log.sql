set serveroutput on size unlimited

define p_schema=&1
define p_table=&2

declare
  l_rowids     varchar2(3);
  l_new_values varchar2(3);
  l_sequence   varchar2(3);
  l_SQL        varchar2(32000);

  cursor c_tabs is
    SELECT owner, table_name
    FROM dba_tables
    WHERE owner = upper('&p_schema')
      AND table_name like upper('&p_table')
      AND secondary = 'N'
      AND temporary = 'N';

  cursor c_log(p_Tab varchar2) is
    SELECT rowids, include_new_values, sequence
    FROM dba_mview_logs
    WHERE log_owner = upper('&p_schema')
      AND master = p_Tab;

begin
  dbms_output.enable(null);
  for t in c_tabs
  loop
    open c_log(t.table_name);
    fetch c_log into l_rowids, l_new_values, l_sequence;
    close c_log;

    if l_rowids is null then
      l_SQL := 'CREATE MATERIALIZED VIEW LOG ON "' || t.owner || '"."' || t.table_name || '" WITH PRIMARY KEY, ROWID, SEQUENCE INCLUDING NEW VALUES';
    elsif l_rowids = 'NO' or l_new_values = 'NO' or l_sequence = 'NO' then
      l_SQL :=  'ALTER MATERIALIZED VIEW LOG FORCE ON "' || t.owner || '"."' || t.table_name || '" ADD PRIMARY KEY, ROWID, SEQUENCE INCLUDING NEW VALUES';
    else
      l_SQL := null;
    end if;

    if l_SQL is not null then
      begin
        dbms_output.put('Adding mview log on "' || t.owner || '"."' || t.table_name || '" - ');
        execute immediate l_SQL;
        dbms_output.put_line('OK');
      exception when others then
        dbms_output.put_line('FAILED: ' || SQLERRM);
      end;
    end if;
  end loop;
end;
/
