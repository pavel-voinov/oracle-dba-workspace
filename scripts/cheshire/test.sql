set linesize 100 heading on feedback off timing off pagesize 0
column ver format a80 heading "MDL Version" justify center
select chesh.getversion as ver from dual;

