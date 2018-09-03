define p_schema=&1
define p_sequence=&2
define p_table=&3
define p_column=&4

/* TODO:
 - check that table/column exists
 - check that column has numeric data type
*/

declare
  max_id number;
  l_cache number;
  l_increment_by number;
  l_cycle varchar2(10);
begin
  dbms_output.enable(null);

  SELECT cache_size, sign(increment_by), cycle_flag INTO l_cache, l_increment_by, l_cycle
  FROM all_sequences
  WHERE sequence_owner = upper('&p_schema')
    AND sequence_name = upper('&p_sequence');

  if l_cycle = 'Y' then
    dbms_output.put_line('Cycled sequences are not supported');
  else
    if l_cache > 0 then
      execute immediate 'ALTER SEQUENCE "' || upper('&p_schema') || '"."' || upper('&p_sequence') || '" NOCACHE';
      dbms_output.put_line('Cache is disabled');
    end if;

    -- prevent updates in the table
    LOCK TABLE &p_schema..&p_table IN EXCLUSIVE MODE;
    dbms_output.put_line('Table is locked for updates');

    -- get current max
    SELECT nvl(max(&p_column * l_increment_by), 0) INTO max_id FROM &p_schema..&p_table;
    dbms_output.put_line('Max value is: ' || to_char(max_id * l_increment_by));

    while max_id >= &p_schema..&p_sequence..nextval * l_increment_by loop
      null;
    end loop;
    dbms_output.put_line('Sequence value is synchronized with table column value');

    -- revert cache_size and release lock on table
    if l_cache > 0 then
      execute immediate 'ALTER SEQUENCE "' || upper('&p_schema') || '"."' || upper('&p_sequence') || '" CACHE ' || l_cache;
      dbms_output.put_line('Cache is enabled back');
    else
      commit;
    end if;
    dbms_output.put_line('Table is unlocked for updates');
  end if;
end;
/
