/*
*/
set termout off
column scn new_value scn
SELECT decode(upper('&scn'), 'USE_CURRENT', to_char(min(current_scn), '99999999999999990'), '&scn') as scn FROM gv$database@&db_link.;
set termout on

PROMPT SCN=&scn

TRUNCATE TABLE &t PURGE MATERIALIZED VIEW LOG;
INSERT INTO &t SELECT * FROM &t@&db_link AS OF SCN &scn;
COMMIT;
