select inst_id, usn, slt, seq, done, ela_mins, est_mins, est_mins - ela_mins as left_mins
from (
select inst_id, usn, slt, seq, round(undoblocksdone/undoblockstotal * 100, 1) as done,
  round(cputime / 60) as ela_mins,
  round(cputime / undoblocksdone * undoblockstotal / 60) est_mins
from gv$fast_start_transactions)
order by 1
/
