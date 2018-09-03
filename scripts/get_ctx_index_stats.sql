set serveroutput on size unlimited long 200000 heading off pagesize 10000 linesize 300

define index_name=&1

col res format a300

set termout off
drop table x$output purge;
set termout on

create table x$output(result CLOB);

declare
  x clob := null;
begin
  ctx_report.index_stats(
    index_name => upper('&index_name'),
    report => x,
    frag_stats => TRUE);

  insert into x$output values (x);
  commit;

  dbms_lob.freetemporary(x);
end;
/

select result as res from x$output;
