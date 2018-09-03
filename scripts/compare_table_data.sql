/*
*/
CREATE OR REPLACE FUNCTION compare_table_data (
  p_TableName         varchar2,
  p_RightSchema       varchar2,
  p_LeftSchema        varchar2,
  p_RightTableName    varchar2 default null,
  p_CompareCountsOnly number default 1)
  return integer
as
  has_lobs exception;
  pragma exception_init(has_lobs, -932);
  has_xmls exception;
  pragma exception_init(has_xmls, -22950);

  l_left_schema  varchar2(30);
  l_right_schema varchar2(30);
  l_left_table   varchar2(30);
  l_right_table  varchar2(30);
  l_cnt1         integer;
  l_cnt2         integer;
  l_cursor       SYS_REFCURSOR;
  l_result       integer;
begin
  l_left_schema := upper(p_LeftSchema);
  l_right_schema := upper(p_RightSchema);
  if l_left_schema = l_right_schema then
    raise_application_error(-20102, 'Schemas must be different');
  end if;
  l_left_table := upper(p_TableName);
  l_right_table := upper(nvl(p_RightTableName, p_TableName));

  l_result := compare_table_struct(p_TableName => l_left_table, p_RightSchema => l_right_schema, p_LeftSchema => l_left_schema,
    p_RightTableName => l_right_table);

  if l_result is not null then
    return l_result;
  end if;

  open l_cursor for 'SELECT count(*) FROM ' || l_left_schema || '.' || l_left_table;
  fetch l_cursor into l_cnt1;
  close l_cursor;
  open l_cursor for 'SELECT count(*) FROM ' || l_right_schema || '.' || l_right_table;
  fetch l_cursor into l_cnt2;
  close l_cursor;

  if l_cnt1 <> l_cnt2 then
    l_result := 1;
  else
    if p_CompareCountsOnly = 1 then
      l_result := null;
    else
      open l_cursor for 'SELECT count(*)
  FROM ((SELECT * FROM ' || l_left_schema || '.' || l_left_table || '
       MINUS
       SELECT * FROM ' || l_right_schema || '.' || l_right_table || ')
      UNION ALL
      (SELECT * FROM ' || l_right_schema || '.' || l_right_table || '
       MINUS
       SELECT * FROM ' || l_left_schema || '.' || l_left_table || '))';
      fetch l_cursor into l_cnt1;
      close l_cursor;

      if l_cnt1 = 0 then
        l_result := null;
      else
        l_result := 1;
      end if;
    end if;
  end if;

  return l_result;
exception
  when has_lobs or has_xmls then
    return compare_table_with_lobs(p_TableName => p_TableName, p_RightSchema => l_right_schema, p_LeftSchema => l_left_schema);
  when others then
    print(l_left_schema || '.' || l_left_table || ' <=> ' || l_right_schema || '.' || l_right_table || ':' || SQLERRM);
end compare_table_data;
/
