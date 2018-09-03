/*
Script is to test availability of Oracle directory for read/write files
*/
declare
  l_dir varchar2(30) := upper('&1');
  l_dir_path varchar2(512);
  l_file utl_file.file_type;

  cursor c_Dir is
    SELECT directory_path
    FROM all_directories
    WHERE directory_name = l_dir;

begin
  dbms_output.enable(null);

  open c_Dir;
  fetch c_Dir into l_dir_path;
  close c_Dir;

  if l_dir_path is null then
    raise_application_error(-20000, 'Oracle directory "' || l_dir || '" is not found or is not accessible');
  end if;

  l_file := utl_file.fopen(location => l_dir, filename => 'test.txt', open_mode => 'w', max_linesize => 1024);
  utl_file.put(l_file, 'Test by "' || user || '" user');
  utl_file.new_line(l_file);
  utl_file.put(l_file, to_char(systimestamp, 'YYYY.MM.DD HH24:MI:SS.FF'));
  utl_file.new_line(l_file);
  utl_file.fflush(l_file);
  utl_file.fclose(l_file);

  dbms_output.put_line('Test is ok. Check "test.txt" file in "' || l_dir_path || '" directory on ' || sys_context('USERENV', 'SERVER_HOST'));
  
exception when others then
  dbms_output.put_line(SQLERRM);
  if utl_file.is_open(l_file) then
    utl_file.fclose(l_file);
  end if;
end;
/
