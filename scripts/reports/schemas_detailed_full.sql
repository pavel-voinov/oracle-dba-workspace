/*
*/
@@reports.inc

column owner format a30 heading "Schema name"
column ts format a80 heading "Tablespaces" word_wrapped
column cnt format a25 heading "Objects count|Invalid/Total"

SELECT owner, cnt_invalid || '/' || cnt_total as cnt, ts FROM (
SELECT t.owner,
  (SELECT count(*) FROM dba_objects WHERE owner = t.owner) as cnt_total,
  (SELECT count(*) FROM dba_objects WHERE owner = t.owner AND status = 'INVALID') as cnt_invalid,
  listagg(t.tablespace_name, ',') within group(order by t.tablespace_name) as ts
FROM (SELECT DISTINCT owner, tablespace_name FROM dba_segments WHERE not regexp_like(owner, '^(SYS(|TEM))$')) t
GROUP BY t.owner
)
ORDER BY 1
/

