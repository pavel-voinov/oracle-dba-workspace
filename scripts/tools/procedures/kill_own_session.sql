/*
*/
CREATE OR REPLACE PROCEDURE kill_own_session (
  p_sid       number,
  p_serial    number default null,
  p_inst_id   number default null,
  p_immediate boolean default true)
  authid definer
as
  l_SQL varchar2(1000);
begin
  for s in (SELECT sid, serial#, inst_id
            FROM gv$session
            WHERE sid = p_sid
              AND (p_serial is null OR serial# = p_serial)
              AND (p_inst_id is null OR inst_id = p_inst_id)
              AND username = sys_context('USERENV', 'SESSION_USER')
              AND status <> 'KILLED')
  loop
    l_SQL := 'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ',@' || s.inst_id || '''';
    if p_immediate then
      execute immediate l_SQL || ' IMMEDIATE';
    else
      execute immediate l_SQL;
    end if;
  end loop;
end kill_own_session;
/
