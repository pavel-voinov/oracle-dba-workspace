select * from dba_synonyms where table_name = 'EMO_EXPERIMENTAL_MODELS';
select * from dba_objects where object_name = 'EMO_EXPERIMENTAL_MODELS';


-- public synonyms
select 'CREATE OR REPLACE PUBLIC SYNONYM ' || synonym_name || ' FOR ' || table_owner || '.' || table_name || ';' as sql_text
from dba_synonyms
where owner = 'PUBLIC' and not regexp_like(table_owner, '^(SYS|SYSTEM|(WM|MD|CTX|OLAP|EXF|ORD|APPQOS)SYS|ORDDATA|OWF_MGR|XDB)$');


select distinct table_owner from dba_synonyms
where owner = 'PUBLIC' and not regexp_like(table_owner, '^(SYS|SYSTEM|(WM|MD|CTX|OLAP|EXF|ORD|APPQOS)SYS|ORDDATA|OWF_MGR|XDB)$');