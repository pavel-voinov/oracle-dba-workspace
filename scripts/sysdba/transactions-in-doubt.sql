select * from DBA_2PC_PENDING;
select * from DBA_2PC_NEIGHBORS;

commit force '&transaction_id';
