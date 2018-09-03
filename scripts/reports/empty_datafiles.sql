@@reports.inc

column tablespace_name format a30 heading "Tablespace"
column file_id format 999990 heading "File ID"
column file_name format a80 heading "File name"

SELECT f.file_id, f.tablespace_name, f.file_name
FROM dba_tablespaces t, dba_data_files f, dba_extents e
WHERE f.tablespace_name = t.tablespace_name
  AND decode(t.contents, 'UNDO', 1, 'TEMPORARY', 2, 0) = 0
  AND f.file_id(+) = e.file_id
  AND f.tablespace_name(+) = e.tablespace_name
GROUP BY f.tablespace_name, f.file_id, f.file_name
HAVING count(e.block_id) > 0
ORDER BY 2, 1
/

declare
  retval number;
begin
  dbms_output.enable(null);
  for f in (SELECT file_name FROM dba_data_files)
  loop
    dbms_space.isdatafiledroppable_name(f.file_name, retval);
    if retval = 1 then
      dbms_output.put_line('"' || f.file_name || '" can be dropped');
    end if;
  end loop;
end;
/
