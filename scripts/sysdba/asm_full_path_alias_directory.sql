-- How To Gather/Backup ASM Metadata In A Formatted Manner version 10.1, 10.2, 11.1, 11.2 and 12.1? (Doc ID 470211.1)
-- Author: Esteban D. Bernal 
-- Property: Oracle Corporation

spool asm1_full_path_alias_directory.html
-- ASM Versions 10.1, 10.2, 11.1  & 11.2
SET MARKUP HTML ON
set echo on

set pagesize 200

alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

select 'THIS ASM REPORT WAS GENERATED AT: ==)> ' , sysdate " "  from dual;


select 'HOSTNAME ASSOCIATED WITH THIS ASM INSTANCE: ==)> ' , MACHINE " " from v$session where program like '%SMON%';

SELECT CONCAT('+'||GNAME, SYS_CONNECT_BY_PATH(ANAME, '/'))
 FULL_PATH, SYSTEM_CREATED, ALIAS_DIRECTORY, FILE_TYPE
 FROM ( SELECT B.NAME GNAME, A.PARENT_INDEX PINDEX,
 A.NAME ANAME, A.REFERENCE_INDEX RINDEX,
 A.SYSTEM_CREATED, A.ALIAS_DIRECTORY,
 C.TYPE FILE_TYPE
 FROM V$ASM_ALIAS A, V$ASM_DISKGROUP B, V$ASM_FILE C
 WHERE A.GROUP_NUMBER = B.GROUP_NUMBER
 AND A.GROUP_NUMBER = C.GROUP_NUMBER(+)
 AND A.FILE_NUMBER = C.FILE_NUMBER(+)
 AND A.FILE_INCARNATION = C.INCARNATION(+)
 )
 START WITH (MOD(PINDEX, POWER(2, 24))) = 0
 CONNECT BY PRIOR RINDEX = PINDEX;


spool off

exit
