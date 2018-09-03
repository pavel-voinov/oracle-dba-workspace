/*
*/
CREATE OR REPLACE FUNCTION compare_table_struct (
  p_TableName      varchar2,
  p_RightSchema    varchar2,
  p_LeftSchema     varchar2,
  p_RightTableName varchar2 default null)
  return integer
as
  l_left_schema  varchar2(30);
  l_right_schema varchar2(30);
  l_left_table   varchar2(30);
  l_right_table  varchar2(30);

  l_cursor    integer;
  l_ignore    integer;
  l_SQL       varchar2(32000);
  l_cnt       integer;
  l_result    integer;

begin
  DBMS_APPLICATION_INFO.SET_MODULE('TOOLS', 'compare_table_struct');

  l_left_schema := upper(p_LeftSchema);
  l_right_schema := upper(p_RightSchema);
  if l_left_schema = l_right_schema then
    raise_application_error(-20102, 'Schemas must be different');
  end if;
  l_left_table := upper(p_TableName);
  l_right_table := upper(nvl(p_RightTableName, p_TableName));

  DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_left_schema || '.' || l_left_table || ' <=> ' || l_right_schema || '.' || l_right_table);

  -- if table doesn't exist in left schema it's probably removed
  if exists_object(p_ObjectName => l_left_table, p_Schema => l_left_schema) = 0 then
    l_result := -2;
  end if;
  -- if table doesn't exist in right schema too it's absent everywhere otherwise
  if exists_object(p_ObjectName => l_right_table, p_Schema => l_right_schema) = 0 then
    if l_result is null then
      l_result := 2;
    else
      l_result := -1;
    end if;
  end if;

  if l_result is not null then
    return l_result;
  end if;

  l_SQL := 'SELECT count(*)
FROM ((SELECT column_name, column_id FROM dba_tab_columns WHERE table_name = :p_left_table AND owner = :p_left_schema
     UNION ALL
     SELECT column_name, column_id FROM dba_tab_columns WHERE table_name = :p_right_table AND owner = :p_right_schema)
    MINUS
    (SELECT column_name, column_id FROM dba_tab_columns WHERE table_name = :p_left_table AND owner = :p_left_schema
     INTERSECT
     SELECT column_name, column_id FROM dba_tab_columns WHERE table_name = :p_right_table AND owner = :p_right_schema))';

  l_cursor := dbms_sql.open_cursor;
  begin
    dbms_sql.parse(l_cursor, l_SQL, dbms_sql.native);
    dbms_sql.bind_variable(l_cursor, ':p_left_schema', l_left_schema);
    dbms_sql.bind_variable(l_cursor, ':p_right_schema', l_right_schema);
    dbms_sql.bind_variable(l_cursor, ':p_left_table', l_left_table);
    dbms_sql.bind_variable(l_cursor, ':p_right_table', l_right_table);

    dbms_sql.define_column(l_cursor, 1, l_cnt);

    l_ignore := dbms_sql.execute(l_cursor);
    if dbms_sql.fetch_rows(l_cursor) > 0 then
      dbms_sql.column_value(l_cursor, 1, l_cnt);
      if l_cnt = 0 then
        l_result := null;
      else
        l_result := 1;
      end if;
    else
      l_result := null;
    end if;
  exception when others then
    if dbms_sql.is_open(l_cursor) then
      dbms_sql.close_cursor(l_cursor);
    end if;
    raise;
  end;

  if dbms_sql.is_open(l_cursor) then
    dbms_sql.close_cursor(l_cursor);
  end if;

  DBMS_APPLICATION_INFO.SET_MODULE(null, null);

  return l_result;
end compare_table_struct;
/
