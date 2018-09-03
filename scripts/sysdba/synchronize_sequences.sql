/*

Script to resync sequence numbers between databases over db_link
*/
define p_db_link=&1

declare
  l_num number;
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for s in (SELECT l.*, r.last_number as old_last_number
            FROM (select sequence_owner, sequence_name, last_number, increment_by
                  from dba_sequences
                  where sequence_owner in (select schema from db_deployment.lm_schemas)
                    and sign(last_number) = sign(increment_by)) l,
                 (select sequence_owner, sequence_name, last_number, increment_by
                  from dba_sequences@db_old_db
                  where sequence_owner in (select schema from db_deployment.lm_schemas)) r
            WHERE l.sequence_owner = r.sequence_owner and l.sequence_name = r.sequence_name
              and abs(r.last_number) > abs(l.last_number))
  loop
    dbms_output.put_line('"' || s.sequence_owner || '"."' || s.sequence_name || '"');
    l_SQL := 'SELECT "' || s.sequence_owner || '"."' || s.sequence_name || '".nextval INTO :p_value FROM dual';
    execute immediate l_SQL into l_num;
    while abs(l_num) < abs(s.old_last_number)
    loop
      execute immediate l_SQL into l_num;
    end loop;
  end loop;
end;
/
/*
check that increment_by and last_number have the same sign or it will be neverending:

select sequence_owner, sequence_name, last_number, increment_by
                  from dba_sequences
                  where sequence_owner in (select schema from db_deployment.lm_schemas)
                    and sign(last_number) <> sign(increment_by);
*/
