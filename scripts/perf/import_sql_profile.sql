declare 
  ar_profile_hints sys.sqlprof_attr; 
  cl_sql_text clob; 
begin 
  select 
  extractvalue(value(d), '/hint') as outline_hints 
  bulk collect 
into 
ar_profile_hints 
from 
xmltable('/*/outline_data/hint' 
passing ( 
select 
xmltype(other_xml) as xmlval 
from 
gv$sql_plan 
where 
sql_id = 'b9apqb9ag8arm' --<-- the sql_id of the good plan
and plan_hash_value = 4066512882   --<-- the hash value of the good plan
and other_xml is not null 
) 
) d; 
select 
sql_text 
into 
cl_sql_text 
from 
dba_hist_sqltext 
where 
sql_id = 'f0xma9b5gya2a';   --<-- the sql_id of the sql we want to stick
dbms_sqltune.import_sql_profile( 
sql_text => cl_sql_text 
, profile => ar_profile_hints 
, category => 'DEFAULT' 
, name => 'PROFILE_f0xma9b5gya2a' --<-- the sql_id of the sql we want to stick (just a label here)
, force_match => TRUE 
); 
end;
/
