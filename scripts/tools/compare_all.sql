set serveroutput on size unlimited timing off feedback off

define p_db_link=&1

spool compare_with_&p_db_link..log

@compare JP_DRUG JPHARM_PUBLIC_B THOR &p_db_link L->R
@compare JP_PF_PATENT_FAMILY JPHARM_PUBLIC_B THOR &p_db_link L->R
@compare JP_SOURCE JPHARM_PUBLIC_B THOR &p_db_link L->R
@compare JP_TRIAL JPHARM_PUBLIC_B THOR &p_db_link L->R
@compare NG_COMPANY_ID JPHARM_PUBLIC_B THOR &p_db_link L->R
@compare NG_DEAL_ID_INVESTIGATIONAL JPHARM_PUBLIC_B THOR &p_db_link L->R
@compare SME_BASIC_PATENT JPHARM_PUBLIC_B THOR &p_db_link L->R

spool off
