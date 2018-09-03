CREATE OR REPLACE PACKAGE BODY dba_utils as

/*
*/

  type TStrings is table of varchar2(4000);
  type TNumbers is table of number;

  g_CurrentSchema constant varchar2(30) := sys_context('USERENV', 'CURRENT_SCHEMA');

procedure print (
  p_Value varchar2,
  p_Title varchar2 default null)
as
  l_length integer;
  l_pos    integer;
begin
  if p_Title is not null then
    dbms_output.put_line(substr(p_Title, 1, 255));
  end if;

  l_pos    := 1;
  l_length := length(p_Value);
  loop
    exit when l_pos > l_length;
    dbms_output.put_line(substr(p_Value, l_pos, 255));
    l_pos := l_pos + 255;
  end loop;
end print;

procedure exec_sql (
  p_SQL clob)
as
  l_cursor pls_integer := dbms_sql.open_cursor;
  sql_table dbms_sql.VARCHAR2S;

  c_buf_len constant binary_integer := 256;
  v_accum  integer := 0;
  v_beg    integer := 1;
  v_end    integer := 256;
  v_loblen pls_integer;
  v_retval pls_integer;

  -- local function to the execute_plsql_block procedure
  function next_row (
    clob_in clob,
    len_in  integer,
    off_in  integer)
    return varchar2
  is
  begin
    return dbms_lob.substr(clob_in, len_in, off_in);
  end next_row;

begin
  v_loblen := dbms_lob.getLength(p_SQL);
  print(lpad('=', 10, '='));
  print(p_SQL);

  loop
    -- Set the length to the remaining size
    -- if there are < c_buf_len characters remaining.
    if v_accum + c_buf_len > v_loblen then
      v_end := v_loblen - v_accum;
    end if;

    sql_table(nvl(sql_table.last, 0) + 1) := next_row(p_SQL, v_end, v_beg);

    v_beg   := v_beg + c_buf_len;
    v_accum := v_accum + v_end;

    if v_accum >= v_loblen then
      exit;
    end if;
  end loop;

  -- Parse the pl/sql and execute it
  dbms_sql.parse(l_cursor, sql_table, sql_table.first, sql_table.last, false, dbms_sql.native);

  begin
    v_retval := dbms_sql.execute(l_cursor);
    dbms_sql.close_cursor(l_cursor);
  exception when others then
    print(SQLERRM);
    dbms_sql.close_cursor(l_cursor);
    raise;
  end;
end exec_SQL;

function exists_object (
  p_ObjectName varchar2,
  p_ObjectType varchar2 default null,
  p_Schema     varchar2 default null,
  p_db_link    varchar2 default null)
  return integer
as
  l_db_link varchar2(255);
  l_SQL     varchar2(32000);
  l_result  integer;
  l_cursor  integer;
  l_cnt     integer;
  l_ignore  integer;
begin
  DBMS_APPLICATION_INFO.SET_MODULE('TOOLS', 'exists_object');

  if p_db_link is not null then
    l_db_link := '@' || p_db_link;
  end if;

  l_SQL := 'SELECT count(*)
FROM dba_objects' || l_db_link || '
WHERE owner = :p_owner
  AND (:p_object_type is null or object_type = :p_object_type)
  AND object_name = :p_object_name';

  l_cursor := dbms_sql.open_cursor;
  begin
    dbms_sql.parse(l_cursor, l_SQL, dbms_sql.native);
    dbms_sql.bind_variable(l_cursor, ':p_owner', nvl(upper(p_Schema), g_CurrentSchema));
    dbms_sql.bind_variable(l_cursor, ':p_object_type', upper(p_ObjectType));
    dbms_sql.bind_variable(l_cursor, ':p_object_name', upper(p_ObjectName));

    dbms_sql.define_column(l_cursor, 1, l_cnt);

    l_ignore := dbms_sql.execute(l_cursor);
    if dbms_sql.fetch_rows(l_cursor) > 0 then
      dbms_sql.column_value(l_cursor, 1, l_cnt);
      if l_cnt = 0 then
        l_result := 0;
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
end exists_object;

function get_unique_key (
  p_TableName varchar2,
  p_Schema    varchar2 default null,
  p_alias     varchar2 default null,
  p_db_link   varchar2 default null)
  return varchar2
as
  l_schema varchar2(30);
  l_result varchar2(4000);
  l_alias  varchar2(255);

  cursor c_Keys is
    SELECT listagg(l_alias || column_name, ',') within group (order by position) as column_names
    FROM dba_cons_columns
    WHERE owner = l_schema AND
      constraint_name = (SELECT constraint_name
                         FROM (SELECT constraint_name
                               FROM (SELECT c.constraint_type, f.constraint_name, count(f.column_name) as cnt_columns
                                     FROM dba_cons_columns f, dba_constraints c
                                     WHERE c.owner = l_schema AND
                                       c.constraint_type IN ('P', 'U') AND
                                       c.table_name = upper(p_TableName) AND
                                       f.owner = c.owner AND
                                       f.constraint_name = c.constraint_name
                                     GROUP BY c.constraint_type, f.constraint_name)
                                ORDER BY decode(constraint_type, 'P', 0, 1), cnt_columns)
                          WHERE rownum = 1);

begin
  l_schema := nvl(upper(p_Schema), g_CurrentSchema);
  if p_alias is null then
    l_alias := '';
  else
    l_alias := trim(p_alias) || '.';
  end if;

  open c_Keys;
  fetch c_Keys into l_result;
  close c_Keys;

  return l_result;
end get_unique_key;

function get_unique_key_condition (
	p_TableName varchar2,
  p_Schema    varchar2 default null,
  p_left_alias varchar2 default 'A',
  p_right_alias varchar2 default 'B',
  p_condition varchar2 default 'AND',
  p_db_link   varchar2 default null)
  return varchar2
as
  l_schema      varchar2(30);
  l_result      varchar2(4000);
  l_left_alias  varchar2(255);
  l_right_alias varchar2(255);
  l_condition   varchar2(10) := ' ' || p_condition || ' ';

  cursor c_Keys is
    SELECT listagg(l_left_alias || column_name || ' = ' || l_right_alias || column_name, l_condition) within group (order by position) as column_names
    FROM dba_cons_columns
    WHERE owner = l_schema AND
      constraint_name = (SELECT constraint_name
                         FROM (SELECT constraint_name
                               FROM (SELECT c.constraint_type, f.constraint_name, count(f.column_name) as cnt_columns
                                     FROM dba_cons_columns f, dba_constraints c
                                     WHERE c.owner = l_schema AND
                                       c.constraint_type IN ('P', 'U') AND
                                       c.table_name = upper(p_TableName) AND
                                       f.owner = c.owner AND
                                       f.constraint_name = c.constraint_name
                                     GROUP BY c.constraint_type, f.constraint_name)
                                ORDER BY decode(constraint_type, 'P', 0, 1), cnt_columns)
                          WHERE rownum = 1);

begin
  l_schema := nvl(upper(p_Schema), g_CurrentSchema);
  if p_left_alias is null then
    l_left_alias := '';
  else
    l_left_alias := trim(p_left_alias) || '.';
  end if;
  if p_right_alias is null then
    l_right_alias := '';
  else
    l_right_alias := trim(p_right_alias) || '.';
  end if;

  open c_Keys;
  fetch c_Keys into l_result;
  close c_Keys;

  return l_result;
end get_unique_key_condition;

function compare_table_struct (
  p_tablename      varchar2,
  p_rightschema    varchar2,
  p_leftschema     varchar2 default null,
  p_righttablename varchar2 default null,
  p_db_link        varchar2 default null)
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
  l_db_link   varchar2(255);

begin
  DBMS_APPLICATION_INFO.SET_MODULE('TOOLS', 'compare_table_struct');

  l_left_schema := upper(p_LeftSchema);
  l_right_schema := upper(p_RightSchema);
  if l_left_schema = l_right_schema and p_db_link is null then
    raise_application_error(-20102, 'Schemas to compare must be different in the same database');
  end if;
  l_left_table := upper(p_TableName);
  l_right_table := upper(nvl(p_RightTableName, p_TableName));

  if p_db_link is not null then
    l_db_link := '@' || p_db_link;
  end if;

  DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_left_schema || '.' || l_left_table || ' <=> ' || l_right_schema || '.' || l_right_table || l_db_link);

  -- if table doesn't exist in left schema it's probably removed
  if exists_object(p_ObjectName => l_left_table, p_Schema => l_left_schema) = 0 then
    l_result := -2;
  end if;
  -- if table doesn't exist in right schema too it's absent everywhere otherwise
  if exists_object(p_ObjectName => l_right_table, p_Schema => l_right_schema, p_db_link => p_db_link) = 0 then
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
       SELECT column_name, column_id FROM dba_tab_columns' || l_db_link || ' WHERE table_name = :p_right_table AND owner = :p_right_schema)
      MINUS
      (SELECT column_name, column_id FROM dba_tab_columns WHERE table_name = :p_left_table AND owner = :p_left_schema
       INTERSECT
       SELECT column_name, column_id FROM dba_tab_columns' || l_db_link || ' WHERE table_name = :p_right_table AND owner = :p_right_schema))';

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
      l_result := sign(l_cnt);
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

function compare_table_with_lobs (
  p_tablename      varchar2,
  p_rightschema    varchar2,
  p_leftschema     varchar2 default null,
  p_righttablename varchar2 default null,
  p_db_link        varchar2 default null)
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
  l_db_link      varchar2(255);
  l_key          varchar2(4000);

  cursor c_PK is
    SELECT f.column_name
    FROM dba_cons_columns f,
      (SELECT table_name, constraint_name
       FROM (SELECT table_name, constraint_name, row_number() over (partition by table_name order by constraint_type) as rn
             FROM dba_constraints c
             WHERE c.owner = l_left_schema AND
               c.constraint_type IN ('P', 'U') AND
               table_name = l_left_table)
       WHERE rn = 1) c
    WHERE f.owner = l_left_schema and c.constraint_name = f.constraint_name;

  cursor c_Lobs is
    SELECT f.column_name, decode(f.data_type, 'XMLTYPE', 1, 0) as is_xml
    FROM dba_tab_columns f, dba_tables t
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

  if p_db_link is not null then
    l_db_link := '@' || p_db_link;
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

function compare_table_data (
  p_tablename         varchar2,
  p_rightschema       varchar2,
  p_leftschema        varchar2 default null,
  p_righttablename    varchar2 default null,
  p_db_link           varchar2 default null,
  p_CompareCountsOnly number default 1,
  p_CompareByUKOnly   number default 1)
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
  l_db_link      varchar2(255);
  l_key          varchar2(4000);
  l_cnt1         integer;
  l_cnt2         integer;
  l_cursor       SYS_REFCURSOR;
  l_result       integer;
begin
  l_left_schema := upper(p_LeftSchema);
  l_right_schema := upper(p_RightSchema);
  if l_left_schema = l_right_schema and p_db_link is null then
    raise_application_error(-20102, 'Schemas to compare must be different in the same database');
  end if;
  l_left_table := upper(p_TableName);
  l_right_table := upper(nvl(p_RightTableName, p_TableName));

  l_result := compare_table_struct(p_TableName => l_left_table, p_RightSchema => l_right_schema, p_LeftSchema => l_left_schema,
    p_RightTableName => l_right_table, p_db_link => p_db_link);

  if l_result <> 0 then
    return l_result;
  end if;

  if p_db_link is not null then
    l_db_link := '@' || p_db_link;
  end if;

  open l_cursor for 'SELECT count(*) FROM ' || l_left_schema || '.' || l_left_table;
  fetch l_cursor into l_cnt1;
  close l_cursor;
  open l_cursor for 'SELECT count(*) FROM ' || l_right_schema || '.' || l_right_table || l_db_link;
  fetch l_cursor into l_cnt2;
  close l_cursor;

  if l_cnt1 <> l_cnt2 then
    l_result := 1;
  else
    if p_CompareCountsOnly = 1 then
      l_result := 0;
    else
      if p_CompareByUKOnly = 1 then
        l_key := get_unique_key(p_Schema => l_left_schema, p_TableName => l_left_table);
      end if;
      if l_key is null then
        l_key := '*';
      end if;

      open l_cursor for 'SELECT *
  FROM ((SELECT ' || l_key || ' FROM ' || l_left_schema || '.' || l_left_table || '
       MINUS
       SELECT ' || l_key || ' FROM ' || l_right_schema || '.' || l_right_table || l_db_link || ')
      UNION ALL
      (SELECT ' || l_key || ' FROM ' || l_right_schema || '.' || l_right_table || l_db_link || '
       MINUS
       SELECT ' || l_key || ' FROM ' || l_left_schema || '.' || l_left_table || '))';
      fetch l_cursor into l_cnt1;
      close l_cursor;

      l_result := sign(l_cnt1);
   end if;
  end if;

  return l_result;
exception
  when has_lobs or has_xmls then
    if p_db_link is null then
      return compare_table_with_lobs(p_TableName => p_TableName, p_RightSchema => l_right_schema, p_LeftSchema => l_left_schema, p_db_link => p_db_link);
    else
      return null;
    end if;
  when others then
    print(l_left_schema || '.' || l_left_table || ' <=> ' || l_right_schema || '.' || l_right_table || l_db_link || ':' || SQLERRM);
    return null;
end compare_table_data;

function table_diff_over_dblink (
  p_TableName   varchar2,
  p_db_link     varchar2,
  p_RightSchema varchar2,
  p_LeftSchema  varchar2 default null,
  p_Direction   varchar2 default 'L->R')
  return SYS_REFCURSOR
as
  l_left_schema  varchar2(30);
  l_right_schema varchar2(30);
  l_table        varchar2(30);
  l_db_link      varchar2(255);
  l_key          varchar2(4000);
  l_cursor       SYS_REFCURSOR;
  l_result       integer;
  l_SQL          varchar2(32000);
begin
  l_left_schema := nvl(upper(p_LeftSchema), g_CurrentSchema);
  l_right_schema := upper(p_RightSchema);

  l_table := upper(p_TableName);

  l_result := compare_table_data(p_TableName => l_table, p_RightSchema => l_right_schema, p_LeftSchema => l_left_schema,
    p_RightTableName => l_table, p_db_link => p_db_link, p_CompareCountsOnly => 1);

  if l_result = 0 then
    l_SQL := 'SELECT null FROM dual WHERE 1 = 0';
  else
    if p_db_link is not null then
      l_db_link := '@' || p_db_link;
    end if;

    l_key := get_unique_key(p_Schema => l_left_schema, p_TableName => l_table);
    if l_key is null then
      l_key := '*';
    end if;

    case p_Direction
      when 'L->R' then
        l_SQL := 'SELECT *
  FROM (SELECT ' || l_key || ' FROM ' || l_left_schema || '.' || l_table || '
        MINUS
        SELECT ' || l_key || ' FROM ' || l_right_schema || '.' || l_table || l_db_link || ')';
      when 'R->L' then
        l_SQL := 'SELECT *
  FROM (SELECT ' || l_key || ' FROM ' || l_right_schema || '.' || l_table || l_db_link || '
        MINUS
        SELECT ' || l_key || ' FROM ' || l_left_schema || '.' || l_table || ')';
    else
      l_SQL := 'SELECT *
  FROM ((SELECT ''L->R'' as direction, ' || l_key || ' FROM ' || l_left_schema || '.' || l_table || '
         MINUS
         SELECT ''L->R'' as direction, ' || l_key || ' FROM ' || l_right_schema || '.' || l_table || l_db_link || ')
        UNION ALL
        (SELECT ''R->L'' as direction, ' || l_key || ' FROM ' || l_right_schema || '.' || l_table || l_db_link || '
         MINUS
         SELECT ''R->L'' as direction, ' || l_key || ' FROM ' || l_left_schema || '.' || l_table || '))';
    end case;
  end if;

  print(l_SQL, 'SQL:');
  open l_cursor for l_SQL;
  return l_cursor;
exception when others then
  print(l_left_schema || '.' || l_table || ' <=> ' || l_right_schema || '.' || l_table || l_db_link || ':' || SQLERRM);
  raise;
end table_diff_over_dblink;

function lob2md5 (
  p_lob in clob)
  return varchar2 deterministic
as
  l_hash raw(4000);
begin
  if p_lob is null then
    return null;
  end if;
  l_hash := dbms_crypto.hash(src => p_lob, typ => dbms_crypto.hash_md5);
  return l_hash;
end lob2md5;

function lob2md5 (
  p_lob in blob)
  return varchar2 deterministic
as
  l_hash raw(4000);
begin
  if p_lob is null then
    return null;
  end if;
  l_hash := dbms_crypto.hash(src => p_lob, typ => dbms_crypto.hash_md5);
  return l_hash;
end lob2md5;

end dba_utils;
/
