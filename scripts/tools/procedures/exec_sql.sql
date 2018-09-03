/*
*/
CREATE OR REPLACE PROCEDURE exec_sql (
  p_SQL clob)
is
  ds_cur    pls_integer := dbms_sql.open_cursor;
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
  dbms_sql.parse(ds_cur, sql_table, sql_table.first, sql_table.last, false, dbms_sql.native);

  begin
    v_retval := dbms_sql.execute(ds_cur);
    dbms_sql.close_cursor(ds_cur);
  exception when others then
    print(SQLERRM);
    dbms_sql.close_cursor(ds_cur);
    raise;
  end;
end exec_sql;
/
GRANT EXECUTE ON exec_sql TO PUBLIC;