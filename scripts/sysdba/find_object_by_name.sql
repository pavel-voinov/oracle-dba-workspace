define obj_name=&1

SELECT owner, object_name, object_type FROM dba_objects WHERE object_name LIKE upper('&obj_name')
ORDER BY 1, 2
/
