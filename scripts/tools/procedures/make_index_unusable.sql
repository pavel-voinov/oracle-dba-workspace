/*
*/
CREATE OR REPLACE PROCEDURE make_index_unusable (
  p_IndexName    varchar2,
  p_Schema       varchar2 default null,
  p_IgnoreErrors boolean default false)
as
  l_schema varchar2(30);
begin
  exec_SQL('ALTER INDEX ' || nvl(p_Schema, sys_context('USERENV', 'CURRENT_SCHEMA')) || '.' || p_IndexName || ' UNUSABLE');
exception when others then
  print(SQLERRM);
  if not p_IgnoreErrors then
    raise;
  end if;
end make_index_unusable;
/
