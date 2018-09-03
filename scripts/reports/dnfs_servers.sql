/*
*/
@@reports.inc

column inst_id format 990 heading "Instance"
column id format 990 heading "ID"
column svrname format a20 heading "Server name"
column dirname format a80 heading "Volume name"
column mntport format 99990 heading "Mnt.Port"
column nfsport format 99990 heading "NFS Port"
column wtmax format 999990 heading "Write Max"
column rtmax format 999990 heading "Read Max"

SELECT inst_id, id, svrname, dirname, mntport, nfsport, wtmax, rtmax
FROM gv$dnfs_servers
ORDER BY svrname, dirname, inst_id
/
