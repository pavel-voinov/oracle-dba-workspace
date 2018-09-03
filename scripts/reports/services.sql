/*
*/
@@reports.inc

column name format a50 heading "Service name"
column network_name format a48 heading "Service's network name"
column taf format a20 heading "TAF|policy/type"
column taf_timing format a20 heading "TAF|retries/delay"
column load_balancing format a30 heading "Load balancing|enabled/advisory/goal"
column aq_ha_notifications format a10 heading "FAN|enabled"
column dtp format a15 heading "DTP|enabled"

SELECT name,
-- network_name,
 decode(failover_method, null, '', failover_method || '/' || failover_type) as taf,
 decode(failover_retries, null, '', failover_retries || '/' || failover_delay) as taf_timing,
 decode(goal, null, '', enabled || '/' || goal || '/' || clb_goal) as load_balancing,
 aq_ha_notifications,
 dtp
FROM dba_services
WHERE not regexp_like(name, '^SYS(\$(BACKGROUND|USERS)$|\.KUPC\$)')
ORDER BY 1
/

