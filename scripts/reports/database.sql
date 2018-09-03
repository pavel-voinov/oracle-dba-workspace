/*
*/
@@reports.inc

set feedback off
column banner format a1024 heading "Database version" word_wrapped

SELECT banner FROM v$version
/

variable v_home varchar2(255)
set termout off
exec dbms_system.get_env('ORACLE_HOME', :v_home);
set termout on

column oname format a40 heading "Option name"
column ovalue format a60 heading "Option value"

PROMPT
PROMPT

SELECT decode(rn,
  1, 'NAME',
  2, 'DB_UNIQUE_NAME',
  3, 'LOG_MODE',
  4, 'FORCE_LOGGING',
  5, 'DATABASE_ROLE',
  6, 'PROTECTION_MODE',
  7, 'PROTECTION_LEVEL',
  8, 'PLATFORM_ID',
  9, 'PLATFORM_NAME',
  10, 'FLASHBACK_ON',
  11, 'SUPPLEMENTAL_LOG_DATA_MIN',
  12, 'SUPPLEMENTAL_LOG_DATA_PK',
  13, 'SUPPLEMENTAL_LOG_DATA_UI',
  14, 'SUPPLEMENTAL_LOG_DATA_ALL',
  15, 'SUPPLEMENTAL_LOG_DATA_FK',
  16, 'SUPPLEMENTAL_LOG_DATA_PL',
  17, 'ARCHIVELOG_COMPRESSION',
  18, 'DATAGUARD_BROKER',
  19, 'GUARD_STATUS',
  20, 'PRIMARY_DB_UNIQUE_NAME',
  21, 'ORACLE_HOME') as oname,
  decode(rn,
  1, name,
  2, db_unique_name,
  3, log_mode,
  4, force_logging,
  5, database_role,
  6, protection_mode,
  7, protection_level,
  8, platform_id,
  9, platform_name,
  10, flashback_on,
  11, supplemental_log_data_min,
  12, supplemental_log_data_pk,
  13, supplemental_log_data_ui,
  14, supplemental_log_data_all,
  15, supplemental_log_data_fk,
  16, supplemental_log_data_pl,
  17, archivelog_compression,
  18, dataguard_broker,
  19, guard_status,
  20, primary_db_unique_name,
  21, :v_home) as ovalue
FROM (SELECT n.rn, d.*
      FROM v$database d, (select rownum as rn from dual connect by level <= 21) n
)
/

set feedback on
