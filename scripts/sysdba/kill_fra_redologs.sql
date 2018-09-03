select 'ALTER DATABASE DROP LOGFILE MEMBER ''' || member || ''';' as sql_text
FROM v$logfile f, v$log l where f.group# = l.group# AND l.status = 'INACTIVE' AND f.member like '+FRA%'
/
