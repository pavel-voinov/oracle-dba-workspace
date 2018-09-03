set serveroutput on size unlimited echo on timing on

declare
  l_hints sys.sqlprof_attr;
  l_sql varchar2(512);
begin
  l_sql := 'insert into zzz_temp_nn (qid, id)
select :CQID_29f9, nc.comp
from noticecomps nc, zzz_temp_nn tmp
where nc.note = tmp.id
  and tmp.qid = :NQID_29f9
union
select :CQID_29f9, qc.comp
from quantity_comp qc, noticequant nq, zzz_temp_nn tmp
where  QC.QUANTITY = NQ.QUANT
  and qc.op != 70
  AND NQ.NOTE = tmp.id
  AND NQ.LINK = 3
  and tmp.qid = :NQID_29f9';
  l_hints := sys.sqlprof_attr();
  l_hints.extend(47);
  l_hints(1) := 'BEGIN_OUTLINE_DATA';
  l_hints(2) := 'IGNORE_OPTIM_EMBEDDED_HINTS';
  l_hints(3) := 'OPTIMIZER_FEATURES_ENABLE(''11.2.0.1'')';
  l_hints(4) := 'DB_VERSION(''11.2.0.1'')';
  l_hints(5) := 'OPT_PARAM(''_optimizer_cost_based_transformation'' ''on'')';
  l_hints(6) := 'OPT_PARAM(''_optimizer_connect_by_cost_based'' ''false'')';
  l_hints(7) := 'OPT_PARAM(''_gby_hash_aggregation_enabled'' ''false'')';
  l_hints(8) := 'ALL_ROWS';
  l_hints(9) := 'OUTLINE_LEAF(@"SEL$1")';
  l_hints(10) := 'OUTLINE_LEAF(@"SEL$5")';
  l_hints(11) := 'OUTLINE_LEAF(@"SEL$4")';
  l_hints(12) := 'OUTLINE_LEAF(@"SEL$6")';
  l_hints(13) := 'OUTLINE_LEAF(@"SET$2")';
  l_hints(14) := 'OUTLINE_LEAF(@"SEL$335DD26A")';
  l_hints(15) := 'MERGE(@"SEL$3")';
  l_hints(16) := 'OUTLINE_LEAF(@"SET$1")';
  l_hints(17) := 'OUTLINE_LEAF(@"INS$1")';
  l_hints(18) := 'OUTLINE(@"SEL$2")';
  l_hints(19) := 'OUTLINE(@"SEL$3")';
  l_hints(20) := 'FULL(@"INS$1" "ZZZ_TEMP_NN"@"INS$1")';
  l_hints(21) := 'FULL(@"SEL$335DD26A" "NQ"@"SEL$2")';
  l_hints(22) := 'NO_ACCESS(@"SEL$335DD26A" "from$_subquery$_007"@"SEL$3")';
  l_hints(23) := 'FULL(@"SEL$335DD26A" "TMP"@"SEL$2")';
  l_hints(24) := 'LEADING(@"SEL$335DD26A" "NQ"@"SEL$2" "from$_subquery$_007"@"SEL$3" "TMP"@"SEL$2")';
  l_hints(25) := 'USE_HASH(@"SEL$335DD26A" "from$_subquery$_007"@"SEL$3")';
  l_hints(26) := 'USE_HASH(@"SEL$335DD26A" "TMP"@"SEL$2")';
  l_hints(27) := 'PX_JOIN_FILTER(@"SEL$335DD26A" "from$_subquery$_007"@"SEL$3")';
  l_hints(28) := 'INDEX_FFS(@"SEL$1" "NC"@"SEL$1" ("NOTICECOMPS"."NOTE" "NOTICECOMPS"."COMP" "NOTICECOMPS"."METHOD"))';
  l_hints(29) := 'FULL(@"SEL$1" "TMP"@"SEL$1")';
  l_hints(30) := 'LEADING(@"SEL$1" "NC"@"SEL$1" "TMP"@"SEL$1")';
  l_hints(31) := 'USE_HASH(@"SEL$1" "TMP"@"SEL$1")';
  l_hints(32) := 'INDEX_FFS(@"SEL$6" "QOPNC"@"SEL$6" ("QOPNC"."QUANTITY" "QOPNC"."NUM" "QOPNC"."COMP"))';
  l_hints(33) := 'INDEX_FFS(@"SEL$6" "QUANTITIES"@"SEL$6" ("QUANTITIES"."ID" "QUANTITIES"."OP"))';
  l_hints(34) := 'LEADING(@"SEL$6" "QOPNC"@"SEL$6" "QUANTITIES"@"SEL$6")';
  l_hints(35) := 'USE_HASH(@"SEL$6" "QUANTITIES"@"SEL$6")';
  l_hints(36) := 'NO_ACCESS(@"SEL$4" "from$_subquery$_008"@"SEL$4")';
  l_hints(37) := 'INDEX_FFS(@"SEL$4" "QUANTITIES"@"SEL$4" ("QUANTITIES"."ID" "QUANTITIES"."OP"))';
  l_hints(38) := 'INDEX_FFS(@"SEL$4" "QOPNC"@"SEL$4" ("QOPNC"."QUANTITY" "QOPNC"."NUM" "QOPNC"."COMP"))';
  l_hints(39) := 'LEADING(@"SEL$4" "from$_subquery$_008"@"SEL$4" "QUANTITIES"@"SEL$4" "QOPNC"@"SEL$4")';
  l_hints(40) := 'USE_HASH(@"SEL$4" "QUANTITIES"@"SEL$4")';
  l_hints(41) := 'USE_HASH(@"SEL$4" "QOPNC"@"SEL$4")';
  l_hints(42) := 'SWAP_JOIN_INPUTS(@"SEL$4" "QUANTITIES"@"SEL$4")';
  l_hints(43) := 'SWAP_JOIN_INPUTS(@"SEL$4" "QOPNC"@"SEL$4")';
  l_hints(44) := 'FULL(@"SEL$5" "QOPNQ"@"SEL$5")';
  l_hints(45) := 'NO_CONNECT_BY_FILTERING(@"SEL$5")';
  l_hints(46) := 'CONNECT_BY_COMBINE_SW(@"SEL$5")';
  l_hints(47) := 'END_OUTLINE_DATA';
  dbms_sqltune.import_sql_profile( sql_text => l_sql, profile => l_hints,  name => 'PROFILE_msearch', force_match => true);
end;
/

