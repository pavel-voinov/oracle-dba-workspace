/*
*/
@@reports.inc
@@db_version

set termout off
column owner format a30 heading "Schema name"
column ts format a140 heading "Tablespaces" word_wrapped

column ts_select new_value ts_select
SELECT case
         when to_number('&&db_version') < 11 then
           'wm_concat(tablespace_name)'
         else
           'listagg(tablespace_name, '','') within group(order by tablespace_name)'
       end as ts_select
FROM dual
/
set termout on

PROMPT Schemas with data (table or index segments):
SELECT owner, to_char(&ts_select) as ts
FROM (SELECT DISTINCT owner, tablespace_name FROM dba_segments)
GROUP BY owner
/

PROMPT Schemas without data (with objects only)
SELECT DISTINCT owner
FROM dba_objects
MINUS
SELECT DISTINCT owner
FROM dba_segments
ORDER BY owner
/

ttitle off
undefine ts_select
