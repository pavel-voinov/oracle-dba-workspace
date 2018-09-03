/*
*/
@@reports.inc

select distinct owner, type, name from dba_source where regexp_like(text, '[^[:space:]]+@[^[:space:]]+');
select * from dba_synonyms where db_link is not null;
