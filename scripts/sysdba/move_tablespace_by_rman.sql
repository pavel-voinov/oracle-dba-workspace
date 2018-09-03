set serveroutput on size 1000000 verify off timing off feedback off linesize 1024 pagesize 9999 heading off long 32000 autotrace off termout off

spool move_ts_&1..rman

column sql_text format a1024 word_wrapped

set termout on

REM Generate script to move datafailes of tablespace &1 to diskgroup &2
PROMPT
PROMPT run {
PROMPT SQL "ALTER TABLESPACE &1 OFFLINE";;

SELECT
  'BACKUP AS COPY DATAFILE ' || f.file# || ' FORMAT ''&2'' TAG ''' || f.file# || 'COPY'';' || chr(10) ||
  'SWITCH DATAFILE ' || f.file# || ' TO DATAFILECOPY TAG ''' || f.file# || 'COPY'';' || chr(10) ||
--  'COPY DATAFILE ' || f.file# || ' TO ''&2'';' || chr(10) ||
--  'SWITCH DATAFILE ' || f.file# || ' TO COPY;' || chr(10) ||
  'RECOVER DATAFILE ' || f.file# || ';' as sql_text
FROM v$datafile f, v$tablespace t
WHERE f.ts# = t.ts# AND t.name like upper('&1');

PROMPT SQL "ALTER TABLESPACE &1 ONLINE";;
PROMPT
PROMPT CROSSCHECK COPY;;
PROMPT DELETE NOPROMPT EXPIRED DATAFILECOPY ALL;;
PROMPT }

spool off

edit move_ts_&1..rman
host rm -i move_ts_&1..rman

