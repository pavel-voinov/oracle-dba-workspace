CREATE OR REPLACE PROCEDURE copy_data (
  p_TableName     varchar2,
  p_SrcSchema     varchar2,
  p_DestSchema    varchar2,
  p_DestTableName varchar2 default null)
as
  l_src_schema varchar2(30);
  l_dst_schema varchar2(30);
  l_src_table  varchar2(30);
  l_dst_table  varchar2(30);

begin
  l_src_schema := upper(p_SrcSchema);
  l_dst_schema := upper(p_DestSchema);
  if l_src_schema = l_dst_schema then
    raise_application_error(-20102, 'Schemas must be different');
  end if;
  l_src_table := upper(p_TableName);
  l_dst_table := nvl(upper(p_DestTableName), l_src_table);

  if compare_table_data(p_TableName => l_src_table, p_LeftSchema => l_src_schema, p_RightSchema => l_dst_schema,
       p_RightTableName => l_dst_table) = 1 then
--    truncate_table(p_TableName => p_TableName, p_Schema => g_CurrentSchema);
    make_indexes_unusable(p_TableName => l_dst_table, p_Schema => l_dst_schema, p_IgnoreErrors => true);
    execute immediate 'INSERT /*+ APPEND NOPARALLEL*/ INTO ' || l_dst_schema || '.' || l_dst_table || ' SELECT * FROM ' || l_src_schema || '.' || l_src_table;
    commit;
    rebuild_indexes(p_TableName => l_dst_table, p_Schema => l_dst_schema, p_IgnoreErrors => true);
  end if;
end copy_data;
/
