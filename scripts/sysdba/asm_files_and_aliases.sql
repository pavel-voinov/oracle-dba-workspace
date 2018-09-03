-- How To Gather/Backup ASM Metadata In A Formatted Manner version 10.1, 10.2, 11.1, 11.2 and 12.1? (Doc ID 470211.1)
-- Author: Esteban D. Bernal 
-- Property: Oracle Corporation

spool asm1_files_and_aliases.html
-- ASM Versions 10.1, 10.2, 11.1  & 11.2
SET MARKUP HTML ON
set echo on

set pagesize 200

COLUMN BYTES FORMAT  9999999999999999

alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

select 'THIS ASM REPORT WAS GENERATED AT: ==)> ' , sysdate " "  from dual;


select 'HOSTNAME ASSOCIATED WITH THIS ASM INSTANCE: ==)> ' , MACHINE " " from v$session where program like '%SMON%';

select * from v$asm_alias;

select * from v$asm_file;

show parameter asm
show parameter cluster
show parameter instance_type
show parameter instance_name
show parameter spfile

show sga

spool off

exit
