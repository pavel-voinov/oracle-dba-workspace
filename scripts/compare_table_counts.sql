/*

Script compares count of tables over db_link. Initially designed to compare schemas involved into replication.
REPLICAT process has to be stopped.
SCN is SCN of source database applied rencently on target - check value of LOG_CMPLT_CSN column in GGS.GGS_CHECPOINT table for specific process.
*/
set serveroutput on timing on echo off linesize 180

define p_schema=&1
define p_db_link=&2
define p_scn=&3

set termout on
declare
  l_scn number := to_number(trim('&p_scn'));
  l_SQL varchar2(32000);
  l_src_cnt number;
  l_tgt_cnt number;
  c SYS_REFCURSOR;
  i integer;
begin
  begin
    SELECT null INTO i FROM dual@&p_db_link;
  exception when others then
    raise_application_error(-20001, 'DB Link is not working');
  end;

  dbms_output.enable(null);
  dbms_output.put_line('SCN (GoldenGate CSN): ' || l_scn);
  dbms_output.put_line('= # =  ' || rpad('== OWNER ', 30, '=') || '  ' || rpad('== TABLE NAME ', 30, '=') || '  ' || rpad('== SRC CNT', 15, '=') || '  ' || rpad('== TGT CNT', 15, '='));
  i := 0;
  for t in (SELECT owner, table_name
            FROM dba_tables
            WHERE owner = upper('&p_schema')
              AND temporary = 'N'
              AND secondary = 'N'
            ORDER BY 1, 2)
  loop
    begin
      open c for 'SELECT count(1) FROM "' || t.owner || '"."' || t.table_name || '"';
      fetch c into l_tgt_cnt;
      close c;
    exception when others then
      l_tgt_cnt := null;
    end;

    begin
      open c for 'SELECT count(1) FROM "' || t.owner || '"."' || t.table_name || '"@&p_db_link AS OF SCN ' || l_scn;
      fetch c into l_src_cnt;
      close c;
    exception when others then
      l_src_cnt := null;
    end;

    if nvl(l_src_cnt, -1) <> nvl(l_tgt_cnt, -1) then
      i := i + 1;
      dbms_output.put_line(lpad(i, 5, ' ') || '  ' || rpad(t.owner, 30, ' ') || '  ' || rpad(t.table_name, 30, ' ') || '  ' || lpad(l_src_cnt, 15, ' ') || '  ' || lpad(l_tgt_cnt, 15, ' '));
      dbms_application_info.set_client_info(t.owner || '.' || t.table_name);
    end if;
  end loop;
  dbms_output.put_line('');
  dbms_output.put_line('Total: ' || i);
end;
/
