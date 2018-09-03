CREATE OR REPLACE PACKAGE dba_utils as

/*
*/

procedure print (
  p_Value varchar2,
  p_Title varchar2 default null);

procedure exec_sql (
  p_SQL clob);

function exists_object (
  p_ObjectName varchar2,
  p_ObjectType varchar2 default null,
  p_Schema     varchar2 default null,
  p_db_link    varchar2 default null)
  return integer;

function get_unique_key (
	p_TableName varchar2,
  p_Schema    varchar2 default null,
  p_alias     varchar2 default null,
  p_db_link   varchar2 default null)
  return varchar2;

function get_unique_key_condition (
	p_TableName varchar2,
  p_Schema    varchar2 default null,
  p_left_alias varchar2 default 'A',
  p_right_alias varchar2 default 'B',
  p_condition varchar2 default 'AND',
  p_db_link   varchar2 default null)
  return varchar2;

function compare_table_struct (
  p_TableName      varchar2,
  p_RightSchema    varchar2,
  p_LeftSchema     varchar2 default null,
  p_RightTableName varchar2 default null,
  p_db_link        varchar2 default null)
  return integer;

function compare_table_with_lobs (
  p_TableName      varchar2,
  p_RightSchema    varchar2,
  p_LeftSchema     varchar2 default null,
  p_RightTableName varchar2 default null,
  p_db_link        varchar2 default null)
  return integer;

function compare_table_data (
  p_TableName         varchar2,
  p_RightSchema       varchar2,
  p_LeftSchema        varchar2 default null,
  p_RightTableName    varchar2 default null,
  p_db_link           varchar2 default null,
  p_CompareCountsOnly number default 1,
  p_CompareByUKOnly   number default 1)
  return integer;

function table_diff_over_dblink (
  p_TableName   varchar2,
  p_db_link     varchar2,
  p_RightSchema varchar2,
  p_LeftSchema  varchar2 default null,
  p_Direction   varchar2 default 'L->R')
  return SYS_REFCURSOR;

function lob2md5 (
  p_lob in clob)
  return varchar2 deterministic;

function lob2md5 (
  p_lob in blob)
  return varchar2 deterministic;

end dba_utils;
/
