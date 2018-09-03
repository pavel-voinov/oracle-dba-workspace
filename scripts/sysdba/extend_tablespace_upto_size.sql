/*
*/

set serveroutput on size 1000000

define tablespace=&1
define max_size=&2

declare
  l_tablespace varchar2(30) := upper('&tablespace');
  l_size_str varchar2(255) := upper('&max_size');
  l_new_size integer;
  l_new_files_count integer;
  l_files_count integer;
  l_power integer;
begin
  if regexp_like(l_size_str, 'G(B|)$', 'i') then
    l_power := 3;
  elsif regexp_like(l_size_str, 'M(B|)$', 'i') then
    l_power := 2;
  elsif regexp_like(l_size_str, 'K(B|)$', 'i') then
    l_power := 1;
  else
    l_power := 0;
  end if;
  l_new_size := to_number(regexp_substr(l_size_str, '^[0-9]*')) * power(2, l_power * 10);
  if l_new_size is null then
    raise_application_error(-20000, 'Parameters with new size have to contain numbers');
  end if;

  -- minimum number of 32Gb files to fit new size of data
  l_new_files_count := ceil(l_new_size / 32 / power(2, 30));
  
  SELECT ceil(sum(bytes) / 32 / power(2, 30)) INTO l_files_count
  FROM dba_segments
  WHERE tablespace_name = l_tablespace;
  
  dbms_output.enable(null);
  for i in 1..(l_new_files_count - l_files_count)
  loop
    dbms_output.put_line('ALTER TABLESPACE ' || l_tablespace || ' ADD DATAFILE SIZE 10M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED');
--    execute immediate 'ALTER TABLESPACE ' || l_tablespace || ' ADD DATAFILE SIZE 10M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
  end loop;
end;
/
