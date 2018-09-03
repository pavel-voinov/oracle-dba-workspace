set scan on

define ident=&1

ALTER SESSION SET sql_trace = TRUE;
ALTER SESSION SET timed_statistics = TRUE;
ALTER SESSION SET tracefile_identifier = '&ident';
ALTER SESSION SET statistics_level = ALL;
--ALTER SESSION SET "_rowsource_execution_statistics" = TRUE;
ALTER SESSION SET events '10046 trace name context forever, level 12';
--ALTER SESSION SET events '10053 trace name context forever, level 1';
