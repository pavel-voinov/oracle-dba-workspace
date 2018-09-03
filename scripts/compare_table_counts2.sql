/*

Script compares count of tables over db_link. Initially designed to compare schemas involved into replication.
REPLICAT process has to be stopped.
This variant of the script accept name of replicat process to get SCN automatically from LOG_CMPLT_CSN column in GGS.GGS_CHECKPOINT table.
*/
set serveroutput on timing on echo off linesize 180

define p_schema=&1
define p_db_link=&2
define p_replicat=&3

set termout on
declare
  l_scn number;
  l_schema varchar2(30) := upper(trim('&p_schema'));
  l_SQL varchar2(32000);
  l_src_cnt number;
  l_tgt_cnt number;
  c SYS_REFCURSOR;
  i integer;

  snapshot_too_old exception;
  pragma exception_init(snapshot_too_old, -1555);
begin
  SELECT log_cmplt_csn INTO l_scn
  FROM ggs.ggs_checkpoint
  WHERE group_name = upper('&p_replicat');

  begin
    SELECT 0 INTO i FROM dual@&p_db_link;
  exception when others then
    raise_application_error(-20001, 'DB Link does not work');
  end;

  dbms_output.enable(null);
  dbms_output.put_line('SCN (GoldenGate CSN): ' || l_scn);
  dbms_output.put_line('= # =  ' || rpad('== OWNER ', 30, '=') || '  ' || rpad('== TABLE NAME ', 30, '=') || '  ' || rpad('== SRC CNT', 15, '=') || '  ' || rpad('== TGT CNT', 15, '='));
  i := 0;
  for t in (SELECT owner, table_name
            FROM dba_tables
            WHERE owner = l_schema
              AND temporary = 'N'
              AND secondary = 'N'
            MINUS
            SELECT owner, table_name                                                                                                                                                                          
            FROM dba_external_tables
            WHERE owner = l_schema
            ORDER BY 1, 2)
  loop
    begin
      open c for 'SELECT count(1) FROM "' || t.owner || '"."' || t.table_name || '"';
      fetch c into l_tgt_cnt;
      close c;
    exception when others then
      l_tgt_cnt := SQLCODE;
    end;

    begin
      open c for 'SELECT count(1) FROM "' || t.owner || '"."' || t.table_name || '"@&p_db_link AS OF SCN ' || l_scn;
      fetch c into l_src_cnt;
      close c;
    exception when others then
      l_src_cnt := SQLCODE;
    end;

    if nvl(l_src_cnt, -1) <> nvl(l_tgt_cnt, -1) then
      i := i + 1;
      dbms_output.put_line(lpad(i, 5, ' ') || '  ' || rpad(t.owner, 30, ' ') || '  ' || rpad(t.table_name, 30, ' ') || '  ' || lpad(case when l_src_cnt < 0 then 'ORA' || l_src_cnt else to_char(l_src_cnt) end, 15, ' ') || '  ' || lpad(case when l_tgt_cnt < 0 then 'ORA' || l_tgt_cnt else to_char(l_tgt_cnt) end, 15, ' '));
      dbms_application_info.set_client_info(t.owner || '.' || t.table_name);
    end if;
    if mod(i, 5) = 0 then
      commit;
    end if;
  end loop;
  dbms_output.put_line('');
  dbms_output.put_line('Total: ' || i);
  commit;
end;
/

undefine p_schema
undefine p_scn
undefine p_db_link
undefine p_replicat
