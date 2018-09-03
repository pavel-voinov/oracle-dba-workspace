sys@ng.perf[3]> set echo on
sys@ng.perf[3]> select
  2       owner, name, queue_type, enqueue_enabled, dequeue_enabled
  3     from
  4       dba_queues
  5     where
  6       owner='SYS'  and
  7       queue_table='SYS$SERVICE_METRICS_TAB' and
  8       queue_type='NORMAL_QUEUE';

OWNER                          NAME                           QUEUE_TYPE                                                   ENQUEUE_ENABLED       DEQUEUE_ENABLED
------------------------------ ------------------------------ ------------------------------------------------------------ --------------------- ---------------------
SYS                            SYS$SERVICE_METRICS            NORMAL_QUEUE                                                   YES                   YES

1 row selected.

Elapsed: 00:00:00.12
sys@ng.perf[3]> exec dbms_aqadm.stop_queue(queue_name => 'SYS.SYS$SERVICE_METRICS');

PL/SQL procedure successfully completed.

Elapsed: 00:00:00.19
sys@ng.perf[3]> select inst_id, value from gv$parameter where name like 'event';

     INST_ID VALUE
------------ --------------------------------------------------
           3
           2
           1

3 rows selected.

Elapsed: 00:00:00.14
sys@ng.perf[3]> alter system set events  '10852 trace name context off';

System altered.

Elapsed: 00:00:00.08
sys@ng.perf[3]> delete from sys.aq$_SYS$SERVICE_METRICS_TAB_L where msgid ='00000000000000000000000000000000';

6700 rows deleted.

Elapsed: 00:00:00.24
sys@ng.perf[3]>    commit;

Commit complete.

Elapsed: 00:00:00.06
sys@ng.perf[3]> DECLARE
  2        po dbms_aqadm.aq$_purge_options_t;
  3     BEGIN
  4        po.block := TRUE;
  5        DBMS_AQADM.PURGE_QUEUE_TABLE(
  6         queue_table     => 'SYS.SYS$SERVICE_METRICS_TAB',
  7         purge_condition => 'qtview.queue =  ''SYS.SYS$SERVICE_METRICS''
  8         and qtview.msg_state = ''PROCESSED''',
  9         purge_options   => po);
 10     END;
 11     /

PL/SQL procedure successfully completed.

Elapsed: 00:00:05.92
sys@ng.perf[3]> commit;

Commit complete.

Elapsed: 00:00:00.07
sys@ng.perf[3]> select
  2       count(*)
  3     from
  4       SYS.aq$_SYS$SERVICE_METRICS_TAB_L
  5     where
  6       msgid ='00000000000000000000000000000000';

    COUNT(*)
------------
           0

1 row selected.

Elapsed: 00:00:00.12
sys@ng.perf[3]> alter system set events '10852 trace name context forever, level 16384';

System altered.

Elapsed: 00:00:00.12
sys@ng.perf[3]>    alter system set event='10852 trace name context forever, level 16384' scope=spfile sid='*';

System altered.

Elapsed: 00:00:00.10
sys@ng.perf[3]> exec dbms_aqadm.start_queue(queue_name => 'SYS.SYS$SERVICE_METRICS');

PL/SQL procedure successfully completed.

Elapsed: 00:00:00.66
sys@ng.perf[3]> PROMPT Doc ID 1162862.1
Doc ID 1162862.1
sys@ng.perf[3]> 
