set serveroutput on size 100000 verify off linesize 180 pagesize 9999

column tablespace_name format a30;
column segment_type format a10;
column owner format a10;
column segment_name format a30;

SELECT tablespace_name, segment_type, owner, segment_name
FROM dba_extents
WHERE file_id = &AFN and &BL between block_id AND block_id + blocks - 1;

begin
  DBMS_REPAIR.ADMIN_TABLES('ORPHAN_KEYS_TABLE', DBMS_REPAIR.ORPHAN_TABLE, DBMS_REPAIR.CREATE_ACTION);
  DBMS_REPAIR.ADMIN_TABLES('REPAIR_TABLE', DBMS_REPAIR.REPAIR_TABLE, DBMS_REPAIR.CREATE_ACTION);
end;
/

DESCRIBE ORPHAN_KEYS_TABLE;
DESCRIBE REPAIR_TABLE;

declare
  l_corrupt_count number;
begin
  DBMS_REPAIR.CHECK_OBJECT(
    schema_name       => '&OWNER',
    object_name       => '&TABLE_TO_RAPAIR',
    object_type       => DBMS_REPAIR.TABLE_OBJECT,
    repair_table_name => 'REPAIR_TABLE',
--    relative_fno      => 22,
--    block_start       => 98523,
--    block_end         => 98524,
    corrupt_count => l_corrupt_count);
    
  DBMS_OUTPUT.PUT_LINE('corrupt_count=' || l_corrupt_count);
end;
/

SELECT * FROM ORPHAN_KEYS_TABLE;
SELECT * FROM REPAIR_TABLE;

begin
  DBMS_REPAIR.SKIP_CORRUPT_BLOCKS (
    schema_name => '&OWNER',
    object_name => '&TABLE_TO_RAPAIR',
    object_type => DBMS_REPAIR.TABLE_OBJECT,
    flags       => DBMS_REPAIR.SKIP_FLAG);
end;
/

declare
  l_fix_count number;
begin
  DBMS_REPAIR.FIX_CORRUPT_BLOCKS (
    schema_name => '&OWNER',
    object_name => '&TABLE_TO_RAPAIR',
    object_type => DBMS_REPAIR.TABLE_OBJECT,
    fix_count   => l_fix_count);
    
  DBMS_OUTPUT.PUT_LINE('fix_count=' || l_fix_count);
end;
/
