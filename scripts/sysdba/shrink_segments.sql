set serveroutput on size unlimited timing on echo on verify off

define schema=&1

spool shrink_&schema..log

begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM dba_tables
            WHERE owner = upper('&schema')
              AND temporary = 'N'
              AND secondary ='N'
            MINUS
            SELECT owner, mview_name
            FROM dba_mviews
            WHERE owner = upper('&schema')
            ORDER By 2) loop
    begin
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" NOLOGGING';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
    begin
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" ENABLE ROW MOVEMENT';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
    begin
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" MOVE';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
    begin
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" SHRINK SPACE CASCADE';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
    begin
      execute immediate 'ALTER TABLE "' || t.owner || '"."' || t.table_name || '" LOGGING';
    exception when others then
      dbms_output.put_line(substr(t.table_name || ': ' || SQLERRM, 1, 255));
    end;
  end loop;
end;
/

@@rebuild_unusable_indexes &schema

spool off
