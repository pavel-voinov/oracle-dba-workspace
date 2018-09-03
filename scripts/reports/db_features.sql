@@reports.inc

column name format a100 heading "Feature name" word_wrapped
column version format a15 heading "Version"
column currently_used format a15 heading "Currently Used"
column detected_usages format 999999990 heading "Detected Usage"

SELECT name, currently_used, version
FROM (SELECT name, currently_used, version, last_sample_date, max(last_sample_date) over (partition by name) as max_last_sample_date
      FROM dba_feature_usage_statistics)
WHERE last_sample_date = max_last_sample_date
ORDER BY name
/
