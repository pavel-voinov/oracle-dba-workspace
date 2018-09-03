/*
*/
ACCEPT t PROMPT "Table name: "
ACCEPT db_link DEFAULT 'jpharm.prod.edc' PROMPT "Database link to source. [jpharm.prod.edc]: "

set termout off
column curr_scn new_value curr_scn
select to_char(min(current_scn), '99999999999999990') as curr_scn from gv$database@&db_link.;
set termout on

ACCEPT scn DEFAULT '&curr_scn' PROMPT "SCN [&curr_scn]: "

@p/sync_table.sql
