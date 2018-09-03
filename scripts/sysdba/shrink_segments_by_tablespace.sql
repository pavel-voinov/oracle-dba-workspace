/*
*/
set serveroutput on size unlimited timing on echo on verify off

define ts=&1
column ts new_value ts
set termout off
SELECT tablespace_name as ts FROM dba_tablespaces WHERE regexp_like(tablespace_name, '^&ts.$', 'i');
set termout on

spool shrink_by_tablespace_&ts..log

declare
  procedure exec_SQL(p_SQL varchar2) is
  begin
    dbms_output.put_line(p_SQL || ';');
    execute immediate p_SQL;
  exception when others then
    dbms_output.put_line(SQLERRM);
  end;

begin
  dbms_output.enable(null);
  for t in (SELECT owner, segment_name, segment_type
            FROM dba_segments WHERE tablespace_name = '&ts'
            ORDER By owner, decode(segment_type, 'TABLE', 0, 'INDEX', 1, 2), segment_name)
  loop
    dbms_application_info.set_client_info(t.segment_type || ': ' || t.owner || '.' || t.segment_name);
    dbms_output.put_line(lpad('=', 60, '='));
    dbms_output.put_line(t.segment_type || ': ' || t.owner || '.' || t.segment_name);
    if t.segment_type = 'TABLE' then
--      exec_SQL('ALTER TABLE "' || t.owner || '"."' || t.segment_name || '" NOLOGGING');
      exec_SQL('ALTER TABLE "' || t.owner || '"."' || t.segment_name || '" ENABLE ROW MOVEMENT');
--      exec_SQL('ALTER TABLE "' || t.owner || '"."' || t.segment_name || '" COMPRESS FOR OLTP');
      exec_SQL('ALTER TABLE "' || t.owner || '"."' || t.segment_name || '" MOVE');
      exec_SQL('ALTER TABLE "' || t.owner || '"."' || t.segment_name || '" SHRINK SPACE CASCADE');
--      exec_SQL('ALTER TABLE "' || t.owner || '"."' || t.segment_name || '" LOGGING');
--    elsif t.segment_type = 'INDEX' then
    end if;
  end loop;
end;
/

spool off
