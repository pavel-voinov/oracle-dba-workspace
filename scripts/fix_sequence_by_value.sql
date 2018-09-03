define p_schema=&1
define p_sequence=&2
define p_value=&3

declare
  max_id number;
begin
  SELECT nvl(&p_value, 0) into max_id FROM dual;
  while max_id >= &p_schema..&p_sequence..nextval loop
    null;
  end loop;
end;
/

exit
