column segment_name format a30
column segment_type format a10
column owner format a10
column tablespace_name format a20

set linesize 160 pagesize 9999 verify off


> dbv USERID=sys/abudfvdctv2 FILE=+ORA1/ggdb/datafile/system.256.665600895

DBVERIFY: Release 10.2.0.4.0 - Production on Tue Dec 16 17:33:15 2008

Copyright (c) 1982, 2007, Oracle.  All rights reserved.

DBVERIFY - Verification starting : FILE = +ORA1/ggdb/datafile/system.256.665600895





------------------------------------

select * from v$database_block_corruption;

SELECT file_id, block_id, segment_name, segment_type, owner, tablespace_name
FROM sys.dba_extents
WHERE  file_id = &bad_file_id AND &bad_block_id BETWEEN block_id AND block_id + blocks - 1;

    FILE_ID     BLOCK_ID SEGMENT_NAME                   SEGMENT_TY OWNER      TABLESPACE_NAME
----------- ------------ ------------------------------ ---------- ---------- --------------------
          1         4562 SMON_SCN_TO_TIME_IDX           INDEX      SYS        SYSTEM
          1        60394 SMON_SCN_TO_TIME               CLUSTER    SYS        SYSTEM
          1        60405 SMON_SCN_TO_TIME               CLUSTER    SYS        SYSTEM

DROP INDEX "SMON_SCN_TIME_SCN_IDX";
CREATE UNIQUE INDEX "SMON_SCN_TIME_SCN_IDX" ON "SMON_SCN_TIME" ("SCN");

select * from V$DATABASE_BLOCK_CORRUPTION;

SELECT owner, table_name 
FROM dba_tables 
WHERE owner='&OWNER' AND cluster_name='&SEGMENT_NAME';
    
TABLE: SMON_SCN_TIME
    

---- 03 April, GGDB:

select * from v$database_block_corruption;
file=3, block=680668, blocks=1, corruption_change#=0, corruption_type=FRACTURED

SELECT file_id, block_id, segment_name, segment_type, owner, tablespace_name
FROM sys.dba_extents
WHERE  file_id = &bad_file_id AND &bad_block_id BETWEEN block_id AND block_id + blocks - 1;

FILE_ID=3
BLOCK_ID=674944
SEGMENT_NAME=_SYSSMU77_2201375864$
SEGMENT_TYPE=UNDO
OWNER=SYS
TABLESPACE_NAME=UNDOTBS1

Elapsed: 00:21:01.55


grid@c111tfx:~> dbv userid=sys file='+UNDO/ggdb/datafile/undotbs1.258.764337445'

DBVERIFY: Release 11.2.0.3.0 - Production on Wed Apr 3 09:15:54 2013

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

DBVERIFY - Verification starting : FILE = +UNDO/ggdb/datafile/undotbs1.258.764337445


DBVERIFY - Verification complete

Total Pages Examined         : 2608640
Total Pages Processed (Data) : 0
Total Pages Failing   (Data) : 0
Total Pages Processed (Index): 0
Total Pages Failing   (Index): 0
Total Pages Processed (Other): 2608640
Total Pages Processed (Seg)  : 50
Total Pages Failing   (Seg)  : 0
Total Pages Empty            : 0
Total Pages Marked Corrupt   : 0
Total Pages Influx           : 0
Total Pages Encrypted        : 0
Highest block SCN            : 0 (0.0)