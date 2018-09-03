define _editor=vi

set serveroutput on size unlimited format wrapped verify off

whenever sqlerror continue

set trimspool on
set long 2048
set linesize 200
set pagesize 9999
set numwidth 12
set arraysize 150
set feedback on
set timing on
set echo off

@column_formats

--set sqlprompt 'SQL> '
alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';
set termout on

-- set autotrace traceonly explain on
