/*
*/
CREATE OR REPLACE FUNCTION compare_table_with_lobs (
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

  l_cursor       SYS_REFCURSOR;

  l_pk_columns   TStrings;
  l_lob_columns  TStrings;
  l_lob_types    TNumbers;
  l_SQL          varchar2(32000);
  l_cnt          integer;

  cursor c_PK is
    SELECT f.column_name
    FROM all_cons_columns f,
      (SELECT table_name, constraint_name
       FROM (SELECT table_name, constraint_name, row_number() over (partition by table_name order by constraint_type) as rn
             FROM all_constraints c
             WHERE c.owner = l_left_schema AND
               c.constraint_type IN ('P', 'U') AND
               table_name = l_left_table)
       WHERE rn = 1) c
    WHERE f.owner = l_left_schema and c.constraint_name = f.constraint_name;

  cursor c_Lobs is
    SELECT f.column_name, decode(f.data_type, 'XMLTYPE', 1, 0) as is_xml
    FROM all_tab_columns f, all_tables t
    WHERE t.owner = l_left_schema AND
      t.table_name = l_left_table AND
      f.owner = t.owner AND
      f.table_name = t.table_name AND
      f.data_type IN ('LOB', 'CLOB', 'BLOB', 'XMLTYPE');

  l_result integer;
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

  open c_PK;
  fetch c_PK bulk collect into l_pk_columns;
  close c_PK;

  if l_pk_columns.count = 0 then
    return null;
  end if;

  open c_Lobs;
  fetch c_Lobs bulk collect into l_lob_columns, l_lob_types;
  close c_Lobs;

  if l_lob_columns.count = 0 then
    return null;
  end if;

  for i in 1..l_lob_columns.count loop
    if l_lob_types(i) = 1 then
      l_lob_columns(i) := 'XMLType(' || l_lob_columns(i) || ').getClobVal()';
    end if;
  end loop;

  l_SQL := 'SELECT count(*)
FROM ' || l_left_schema || '.' || l_left_table || ' a, ' || l_right_schema || '.' || l_right_table || ' b
WHERE ';

  for i in 1..l_pk_columns.count loop
    if i > 1 then
      l_SQL := l_SQL || ' AND ';
    end if;
    l_SQL := l_SQL || 'a.' || l_pk_columns(i) || ' = b.' || l_pk_columns(i);
  end loop;
  l_SQL := l_SQL || ' AND
(';
  for i in 1..l_lob_columns.count loop
    if i > 1 then
      l_SQL := l_SQL || ' OR ';
    end if;
    l_SQL := l_SQL || 'dbms_lob.compare(a.' || l_lob_columns(i) || ', b.' || l_lob_columns(i) || ') <> 0';
  end loop;
  l_SQL := l_SQL || ')';

  open l_cursor for l_SQL;
  fetch l_cursor into l_cnt;
  close l_cursor;
  if l_cnt > 0 then
    l_result := 1;
  else
    l_result := null;
  end if;

  return l_result;
exception
  when others then
    raise;
end compare_table_with_lobs;
/
