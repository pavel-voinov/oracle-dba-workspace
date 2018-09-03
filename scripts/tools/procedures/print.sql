/*
*/
CREATE OR REPLACE PROCEDURE print (p_Value varchar2, p_Title varchar2 default null) is
  l_lenght integer;
  l_pos    integer;
begin
  if p_Title is not null then
    DBMS_OUTPUT.put_line(substr(p_Title, 1, 255));
  end if;

  l_pos    := 1;
  l_lenght := length(p_Value);
  loop
    exit when l_pos > l_lenght;
    dbms_output.put_line(substr(p_Value, l_pos, 255));
    l_pos := l_pos + 255;
  end loop;
end print;
/
