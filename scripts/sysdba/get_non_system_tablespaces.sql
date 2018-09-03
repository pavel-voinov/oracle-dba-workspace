
set serveroutput on size unlimited verify off timing off autotrace off heading off feedback off newpage none linesize 20000 trimspool on pagesize 9999

column sql_text format a4000

SELECT 'CREATE ' || decode(contents, 'PERMANENT', '', 'TEMPORARY', 'TEMPORARY ') || 'TABLESPACE ' || tablespace_name ||
  decode(contents, 'PERMANENT', ' SEGMENT SPACE MANAGEMENT AUTO', 'TEMPORARY', ' EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1024K') || chr(10) ||
  decode(contents, 'PERMANENT', ' DATAFILE', 'TEMPORARY', ' TEMPFILE') ||
  (SELECT listagg(' ''+DATA'' SIZE 10M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED', ',' || chr(10)) within group (order by rownum)
   FROM dual
   CONNECT BY level <= min_files_count) || chr(10) || '/' as sql_text
FROM (SELECT t.tablespace_name, t.contents, nvl(sum(s.size_mb), 10) as size_mb, nvl(ceil(sum(s.size_mb) / 32768), 1) as min_files_count
      FROM dba_tablespaces t,
        (SELECT tablespace_name, ceil(sum(bytes) / 1024 / 1024) as size_mb
         FROM dba_segments
         WHERE not regexp_like(owner, '^(SYS(|TEM)|XD(B|K)|WIRELESS|MD(SYS|DATA)|ZABBIX|SCOTT|DBSNMP|(OLAP|CTX|EXF|APPQOS|WCR|WM)SYS|ANONYMOUS|FLOWS_FILES|ORACLE_OCM|ORD(DATA|PLUGINS|SYS)|OUTLN|SI_INFORMTN_SCHEMA|DIP|XS\$NULL|SPATIAL_(CSW|WFS)_ADMIN_USR|OWBSYS(|_AUDIT))$')
         GROUP BY tablespace_name) s
      WHERE t.tablespace_name = s.tablespace_name(+)
        AND t.tablespace_name not in ('USERS', 'SYSAUX', 'SYSTEM', 'TEMP')
        AND t.contents IN ('PERMANENT', 'TEMPORARY')
      GROUP BY t.tablespace_name, t.contents)
ORDER BY tablespace_name
/
