#!/bin/bash


$ORACLE_HOME/bin/sqlplus / as sysdba << EOF
set serveroutput on size 1000000 echo off timing off linesize 180 pagesize 9999 feedback off verify off

define directory_path=''
define date_stamp=''
column directory_path new_value directory_path
column date_stamp new_value date_stamp

select directory_path from dba_directories where directory_name = 'DATAPUMP_DIR';
select to_char(sysdate, 'YYYYMMDD') as date_stamp from dual;

spool &directory_path/state_&date_stamp..log

create pfile='&directory_path/init_&date_stamp..ora' from spfile;

host rm -f &directory_path/controlfile_&date_stamp..sql
alter database backup controlfile to trace as '&directory_path/controlfile_&date_stamp..sql';

column directory_name format a30
column directory_path format a140 word_wrap
column tablespace_name format a30 heading "Tablespace"
column content_type format a10 heading "Type"
column files_count format 9990 heading "Files count"
column size_mb format 999,999,990 heading "Size, Mb"
column max_size_mb format 999,999,990 heading "Mac size, Mb"
column min_files_count format 9990 heading "Min files count"
column schema_user format a30 heading "Schema"

PROMPT =========================
PROMPT Directories:
PROMPT =========================
SELECT directory_name, directory_path
FROM dba_directories
ORDER BY 1
/
PROMPT =========================
PROMPT Tablespaces:
PROMPT =========================
SELECT tablespace_name, content_type, files_count, size_mb, max_size_mb, ceil(size_mb / 32768) as min_files_count
FROM (SELECT f.tablespace_name, t.contents as content_type,
        count(f.file_id) as files_count,
        ceil(sum(f.bytes) / 1024 / 1024) as size_mb,
        ceil(sum(f.maxbytes) / 1024 / 1024) as max_size_mb
      FROM dba_data_files f, dba_tablespaces t
      WHERE t.tablespace_name = f.tablespace_name
      GROUP BY f.tablespace_name, t.contents)
ORDER BY tablespace_name, content_type
/
PROMPT =========================
PROMPT Tablespaces by schemas:
PROMPT =========================
SELECT owner as schema_user, tablespace_name, size_mb, ceil(size_mb / 32768) as min_files_count
FROM (SELECT owner, tablespace_name, ceil(sum(bytes) / 1024 / 1024) as size_mb
      FROM dba_segments
      GROUP BY owner, tablespace_name)
ORDER BY schema_user, tablespace_name
/
spool off
EOF
