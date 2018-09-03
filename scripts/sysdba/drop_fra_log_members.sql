set serveroutput on size unlimited

set term off
column fra_path new_value fra_path
SELECT value as fra_path FROM v$parameter WHERE name = 'db_recovery_file_dest';
set term on

PROMPT FRA path is "&fra_path"

begin
  dbms_output.enable(null);
  for f in (SELECT 'ALTER DATABASE DROP LOGFILE MEMBER ''' || member || '''' as sql_text
            FROM v$logfile f, v$log l
            WHERE f.group# = l.group# AND l.status not in ('ACTIVE', 'CURRENT') AND f.member like '&fra_path.%/%')
  loop
    dbms_output.put_line(f.sql_text || ';');
    execute immediate f.sql_text;
  end loop;
end;
/
