/*
*/
CREATE OR REPLACE FUNCTION "BARSTRMADM"."CLOB2MD5_REMOTE" (
  p_owner varchar2,
  p_table_name varchar2,
  p_column_name varchar2,
  p_id_column varchar2,
  p_id_value number)
  return varchar2 deterministic
as
  l_hash varchar2(4000);
  l_cursor number;
  l_ignore integer;
begin
  l_cursor := dbms_sql.open_cursor;
  begin
    dbms_sql.parse(l_cursor, 'SELECT clob2md5("' || p_column_name || '") FROM "' || p_owner || '"."' || p_table_name || '" WHERE "' || p_id_column || '" = :p_id', dbms_sql.native);
    dbms_sql.bind_variable(l_cursor, ':p_id', p_id_value);
    dbms_sql.define_column(l_cursor, 1, l_hash, 4000);

    l_ignore := dbms_sql.execute(l_cursor);
    if dbms_sql.fetch_rows(l_cursor) > 0 then
      dbms_sql.column_value(l_cursor, 1, l_hash);
    else
      l_hash := null;
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

  return l_hash;
end clob2md5_remote;
/
