/*
*/
define p_schema=&1
define p_new_ts=&2

column ts format a140 heading "Tablespaces" word_wrapped

SELECT listagg(tablespace_name || upper(':&p_new_ts'), ',') within group (order by tablespace_name) as ts
FROM (SELECT default_tablespace as tablespace_name FROM dba_users WHERE username = upper('&p_schema')
      UNION
      SELECT DISTINCT tablespace_name
      FROM dba_segments
      WHERE owner = upper('&p_schema'))
WHERE tablespace_name <> upper('&p_new_ts')
/
