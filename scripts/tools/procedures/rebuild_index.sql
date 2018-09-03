/*
*/
CREATE OR REPLACE PROCEDURE rebuild_index (
  p_IndexName    varchar2,
  p_Schema       varchar2 default null,
  p_IgnoreErrors boolean default false)
as
begin
  exec_SQL('ALTER INDEX ' || nvl(p_Schema, sys_context('USERENV', 'CURRENT_SCHEMA')) || '.' || p_IndexName || ' REBUILD');
exception when others then
  print(SQLERRM);
  if not p_IgnoreErrors then
    raise;
  end if;
end rebuild_index;
/
