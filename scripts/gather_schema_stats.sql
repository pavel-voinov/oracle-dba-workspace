set serveroutput on size unlimited timing on

define schema=&1

begin
--  dbms_stats.delete_schema_stats(ownname => upper('&schema'));
  dbms_stats.gather_schema_stats(
      ownname     => upper('&schema'),
      options     => 'GATHER AUTO',
      method_opt  => 'FOR ALL COLUMNS SIZE SKEWONLY',
      estimate_percent => dbms_stats.auto_sample_size,
      gather_temp => false,
      cascade     => true,
      degree      => dbms_stats.auto_degree);
end;
/
