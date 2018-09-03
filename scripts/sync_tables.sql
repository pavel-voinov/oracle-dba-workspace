/*
*/
set serveroutput on size unlimited

define p_owner=&1
define p_tables=&2
define p_db_link=&3
define p_scn=&4

set termout off
column p_scn new_value p_scn
SELECT decode(upper('&p_scn'), 'USE_CURRENT', to_char(min(current_scn), '99999999999999990'), '&scn') as scn FROM gv$database@&p_db_link.;
set termout on

PROMPT SCN=&p_scn

begin
  dbms_output.enable(null);
  for t in (SELECT owner, table_name
            FROM dba_tables
            WHERE owner = upper('&p_owner')
              AND regexp_like(table_name, '^(' || replace('&p_tables', ',', '|') || ')$', 'i'))
  loop
    begin
      dbms_output.put(t.owner || '.' || t.table_name);
      execute immediate 'TRUNCATE TABLE "' || t.owner || '"."' || t.table_name || '" PURGE MATERIALIZED VIEW LOG';
      execute immediate 'INSERT INTO "' || t.owner || '"."' || t.table_name || '" SELECT * FROM "' || t.owner || '"."' || t.table_name || '"@&p_db_link AS OF SCN &p_scn';
      COMMIT;
      dbms_output.put_line(': ok');
    exception when others then
      dbms_output.put_line(': ' || SQLERRM);
    end;
  end loop;
end;
/
