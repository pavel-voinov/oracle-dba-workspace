/*

Script is based on MetaLink Doc ID 452341.1 (ORA-01555 And Other Errors while Exporting Table With LOBs, How To Detect Lob Corruption)
*/
set serverout on size unlimited

define p_table=&1
define p_column=&2

exec dbms_output.enable(null);
declare
  pag    number;
  len    number;
  c      varchar2(10);
  charpp number := 8132/2;
begin
  for r in (select rowid rid, dbms_lob.getlength(&p_column) len
            from   &p_table)
  loop
    if r.len is not null then
      for page in 0..r.len/charpp loop
        begin
          select dbms_lob.substr(&p_column, 1, 1+ (page * charpp))
          into   c
          from   &p_table
          where  rowid = r.rid;
        
        exception
          when others then
            dbms_output.put_line ('Error on rowid ' || r.rid || ' page ' || page);
            dbms_output.put_line (SQLERRM);
        end;
      end loop;
    end if;
  end loop;
end;
/

undefine p_table
undefine p_column
