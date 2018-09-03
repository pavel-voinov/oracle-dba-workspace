/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all synonyms from schema &schema with missed targets (except those with db_links):

declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT s.owner, s.synonym_name, s.table_owner, s.table_name
            FROM dba_synonyms s
            WHERE owner = upper('&schema')
              AND instr(s.table_name, '/') = 0
              AND db_link is null
              AND not exists (SELECT null FROM dba_objects o WHERE o.owner = s.table_owner AND o.object_name = s.table_name))
  loop
    l_SQL := 'DROP SYNONYM "' || t.owner || '"."' || t.synonym_name || '"';
    begin
      dbms_output.put(l_SQL);
      execute immediate l_SQL;
      dbms_output.put_line(' - OK');
    exception when others then
      dbms_output.put_line(':' || SQLERRM);
    end;
  end loop;
end;
/
