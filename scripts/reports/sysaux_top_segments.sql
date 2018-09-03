/*
*/
@@reports.inc

col SgmntSize heading 'Sgmnt|Size|Mb'
col SgmntSize format 99999
col TSname heading 'TSpace|Name|'
col TSname format a25
col SgmntOwner heading 'Sgmnt|Owner|'
col SgmntOwner format a15
col SgmntName heading 'Sgmnt|Name|'
col SgmntName format a35
col SgmntType heading 'Sgmnt|Type|'
col SgmntType format a5

SELECT * FROM (
SELECT
  ROUND(SUM(ds.bytes)/1024/1024,0) as "SgmntSize",
  ds.TableSpace_name as "TSname",
  ds.owner as "SgmntOwner",
  ds.segment_name as "SgmntName",
  ds.segment_type as "SgmntType"
FROM dba_segments ds
WHERE ds.segment_type IN ('TABLE','INDEX')
AND TableSpace_name = 'SYSAUX'
GROUP BY
  ds.TableSpace_name,
  ds.owner,
  ds.segment_name,
  ds.segment_type
ORDER BY "SgmntSize" DESC)
WHERE rownum <= 20
/
