/*
*/
CREATE OR REPLACE PROCEDURE make_indexes_unusable (
  p_TableName    varchar2 default null,
  p_Schema       varchar2 default null,
  p_IgnoreErrors boolean default false)
as
  l_schema varchar2(30);
begin
  l_schema := nvl(upper(p_Schema), sys_context('USERENV', 'CURRENT_SCHEMA'));
  for r in (SELECT index_name
            FROM all_indexes
            WHERE owner = l_schema
              AND (p_TableName is null OR table_name = upper(p_TableName))
              AND index_type like '%NORMAL%'
              AND status = 'VALID'
              AND uniqueness = 'NONUNIQUE') loop
    make_index_unusable(p_IndexName => r.index_name, p_Schema => l_schema, p_IgnoreErrors => p_IgnoreErrors);
  end loop;
end make_indexes_unusable;
/
