set serveroutput on size unlimited verify off timing off feedback off linesize 32000 pagesize 0 heading off long 2000000 autotrace off newpage none termout on trimspool on


PROMPT Saving DDL for &1 &2 into &3

set termout off

define file_name='&3'
column file_name new_value file_name
column obj_owner new_value obj_owner
column obj_name new_value obj_name
column obj_type new_value obj_type
column uobj_type new_value uobj_type

SELECT upper('&1') as uobj_type, regexp_replace(upper('&1'), '^(PACKAGE|TYPE)(_SPEC|_BODY)$', '\1') as obj_type, replace('&file_name', '$', '\$') as file_name
FROM dual
/

whenever sqlerror exit failure

SELECT owner as obj_owner, object_name as obj_name
FROM all_objects
WHERE owner || '.' || object_name = replace('&2', '"')
  AND object_type = '&obj_type'
  AND rownum = 1
/

begin
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', false);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'CONSTRAINTS', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'CONSTRAINTS_AS_ALTER', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'OID', false);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'FORCE', true);
end;
/
column sql_text format a32000 word_wrapped

variable rep REFCURSOR

--set termout off

spool &file_name append

SELECT --to_clob('set serveroutput on size unlimited timing off define off scan off verify off
--') || 
  case
    when regexp_like(object_type, '(PACKAGE.*|TYPE.*)') then
      sql_text
    when object_type in ('FUNCTION', 'PROCEDURE') then
      regexp_replace(sql_text, '(end;|;)[[:space:].]*(/)[[:space:].]*$', '\1' || chr(10) || '/', 1, 0, 'imn')
    when object_type = 'TRIGGER' then
      regexp_replace(
        regexp_replace(sql_text, '(end;)[[:space:].]*(/)$', '\1' || chr(10) || '\2', 1, 0, 'imn'),
          'ALTER[[:space:]]+TRIGGER[[:space:]]+\".*\"[[:space:]]+(ENABLE|DISABLE)[[:space:]]*\;[[:space:]]*$', '', 1, 1, 'imn')
    else
      regexp_replace(sql_text, '\;[[:space:]]*$', chr(10) || '/', 1, 0, 'mn')
  end as sql_text
FROM (
  SELECT regexp_replace(dbms_metadata.get_ddl(replace('&uobj_type', ' ', '_'), object_name, owner),
           '^[[:space:]]*(CREATE |ALTER |GRANT |COMMENT )', '\1', 1, 0, 'im') as sql_text, object_type
  FROM all_objects o
  WHERE owner = '&obj_owner' AND object_name = '&obj_name' AND object_type = '&obj_type'
    AND (NOT regexp_like('&uobj_type', '(PACKAGE|TYPE)_BODY') OR
         EXISTS (SELECT null FROM all_source s WHERE s.owner = o.owner AND s.name = o.object_name AND s.type = replace('&uobj_type', '_', ' ')))
)
/
declare
  l_cnt number;
begin
  if '&uobj_type' IN ('TABLE', 'MATERIALIZED VIEW') then
    SELECT count(*) into l_cnt
    FROM all_indexes i, all_objects o
    WHERE o.owner = '&obj_owner'
      AND o.object_type = '&uobj_type'
      AND o.object_name = '&obj_name'
      AND i.owner = o.owner
      AND i.table_name = o.object_name
      AND not exists (SELECT null FROM all_constraints c
                      WHERE c.owner = o.owner AND c.constraint_type IN ('P', 'U')
                        AND c.index_name = i.index_name);
  else
    l_cnt := 0;
  end if;

  if l_cnt > 0 then
    open :rep for
      SELECT regexp_replace(dbms_metadata.get_ddl('INDEX', i.index_name, i.owner), '\;[[:space:]]*$', chr(10) || '/', 1, 0, 'mn') as sql_text
      FROM all_indexes i, all_objects o
      WHERE o.owner = '&obj_owner'
        AND o.object_type = '&uobj_type'
        AND o.object_name = '&obj_name'
        AND i.owner = o.owner
        AND i.table_name = o.object_name
        AND not exists (SELECT null FROM all_constraints c
                        WHERE c.owner = o.owner
                          AND c.constraint_type IN ('P', 'U')
                          AND c.index_name = i.index_name);
  else
    open :rep for
      SELECT null as sql_text FROM dual;
  end if;
end;
/
print :rep

declare
  l_cnt number;
begin
  if '&uobj_type' = 'TABLE' then
    SELECT count(*) into l_cnt
    FROM all_mview_logs
    WHERE log_owner = '&obj_owner'
      AND master = '&obj_name';
  else
    l_cnt := 0;
  end if;

  if l_cnt > 0 then
    open :rep for
      SELECT regexp_replace(dbms_metadata.get_dependent_ddl('MATERIALIZED_VIEW_LOG', '&obj_name', '&obj_owner'), '\;[[:space:]]*$', chr(10) || '/', 1, 0, 'mn') as sql_text
      FROM dual;
  else
    open :rep for
      SELECT null as sql_text FROM dual;
  end if;
end;
/
print :rep

declare
  l_cnt number;
begin 
  if '&uobj_type' = 'MATERIALIZED VIEW' then
    SELECT count(*) into l_cnt
    FROM all_refresh_children
    WHERE owner = '&obj_owner'
      AND name = '&obj_name'
      AND type = 'SNAPSHOT';
  else
    l_cnt := 0;
  end if;

  if l_cnt > 0 then
    open :rep for
      SELECT 'exec dbms_refresh.add(name => ''"' || rowner || '"."' || rname || '"'', list => ''"' || owner || '"."' || name || '"'', lax => true);' as sql_text
      FROM all_refresh_children
      WHERE owner = '&obj_owner'
        AND name = '&obj_name'
        AND type = 'SNAPSHOT';
  else
    open :rep for
      SELECT null as sql_text FROM dual;
  end if;
end;
/
print :rep

set termout on

spool off

exit
