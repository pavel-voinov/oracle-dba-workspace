set serveroutput on size unlimited timing on echo on verify off

spool shrink_&p_schema..log

begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM all_tables
            WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
              AND temporary = 'N'
              AND secondary ='N'
            MINUS
            SELECT owner, mview_name
            FROM all_mviews
            WHERE owner = sys_context('USERENV', 'CURRENT_SCHEMA')
            ORDER By 2) loop
    begin
      dbms_ouput.put_line('ALTER TABLE "' || t.owner || '"."' || t.table_name || '" NOLOGGING');
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" NOLOGGING';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
    begin
      dbms_ouput.put_line('ALTER TABLE "' || t.owner || '"."' || t.table_name || '" ENABLE ROW MOVEMENT');
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" ENABLE ROW MOVEMENT';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
    begin
      dbms_ouput.put_line('ALTER TABLE "' || t.owner || '"."' || t.table_name || '" MOVE');
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" MOVE';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
    begin
      dbms_ouput.put_line('ALTER TABLE "' || t.owner || '"."' || t.table_name || '" SHRINK SPACE CASCADE');
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" SHRINK SPACE CASCADE';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
    begin
      dbms_ouput.put_line('ALTER TABLE "' || t.owner || '"."' || t.table_name || '" LOGGING');
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" LOGGING';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
  end loop;
end;
/

@@rebuild_unusable_indexes

spool off
