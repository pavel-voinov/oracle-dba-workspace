/*

Workaround to fix issues on import tables with columns with "TIMESTAMP WITH TIMEZONE" data types.
(Based on MetaLink Note 1459430.1)
Initially was required for THOR and THOR_DELTA users on NG databases.
*/
GRANT lock any table TO imp_full_database;
GRANT alter any index TO imp_full_database;
