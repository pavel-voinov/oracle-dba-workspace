select * from (
select * from dba_audit_trail where owner = 'DEVEL' order by timestamp desc
)
where rownum <= 15;

select * from dba_audit_trail where obj_name like 'UNITLOGS_%' and action_name <> 'SELECT' order by timestamp desc;

select * from dba_common_audit_trail;

select * from dba_objects where object_name like '%AUDIT%';

NOAUDIT ALL BY devel;

AUDIT ALL BY devel BY ACCESS;
AUDIT ALL BY tester BY ACCESS;
AUDIT ALL BY bundle BY ACCESS;
AUDIT ALL BY devel BY ACCESS;
AUDIT ALL BY gg_updates BY ACCESS;
AUDIT ALL BY gvdb_api BY ACCESS;
AUDIT ALL BY updates BY ACCESS;
AUDIT ALL BY updates2 BY ACCESS;


begin
  dbms_output.enable(null);
  for t in (
SELECT *
FROM (SELECT x.owner, x.object_name, decode(d.rn, 1, a1, 2, a2, 3, a3, 4, a4, 5, a5, 6, a6, 7, a7, 8, a8, 9, a9, 10, a10, 11, a11, 12, a12, 13, a13, 14, a14, 15, a15, 16, a16, 17, a17) as action_name
      FROM (SELECT owner, object_name,
              decode(alt, '-/-', NULL, '/', NULL, 'ALTER') as a1,
              decode(AUD, '-/-', NULL, '/', NULL, 'AUDIT') as a2,
              decode(com, '-/-', NULL, '/', NULL, 'COMMENT') as a3,
              decode(del, '-/-', NULL, '/', NULL, 'DELETE') as a4,
              decode(gra, '-/-', NULL, '/', NULL, 'GRANT') as a5,
              decode(ind, '-/-', NULL, '/', NULL, 'INDEX') as a6,
              decode(ins, '-/-', NULL, '/', NULL, 'INSERT') as a7,
              decode(loc, '-/-', NULL, '/', NULL, 'LOCK') as a8,
              decode(ren, '-/-', NULL, '/', NULL, 'RENAME') as a9,
              decode(sel, '-/-', NULL, '/', NULL, 'SELECT') as a10,
              decode(upd, '-/-', NULL, '/', NULL, 'UPDATE') as a11,
              decode(ref, '-/-', NULL, '/', NULL, 'REFRERENCE') as a12,
              decode(exe, '-/-', NULL, '/', NULL, 'EXECUTE') as a13,
              decode(cre, '-/-', NULL, '/', NULL, 'CREATE') as a14,
              decode(rea, '-/-', NULL, '/', NULL, 'READ') as a15,
              decode(wri, '-/-', NULL, '/', NULL, 'WRITE') as a16,
              decode(fbk, '-/-', NULL, '/', NULL, 'FLASHBACK') as a17
            FROM (select u.name owner, o.name object_name, t.audit$, substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1) alt, substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1) aud, substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1) com, substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1) del, substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1) gra, substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1) ind, substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1) ins, substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1) loc, substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1) ren, substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1) sel, substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1) upd, '-/-' ref, /* dummy REF column */ substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1) exe, substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1) cre, substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1) rea, substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1) wri, substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1) fbk from sys.obj$ o, sys.user$ u, sys.tab$ t where o.type# = 2 and not (o.owner# = 0 and o.name = '_default_auditing_options_') and (instrb(t.audit$,'S') != 0 or instrb(t.audit$,'A') != 0) and o.owner# = u.user# and o.obj# = t.obj# union all select u.name owner, o.name object_name, 'VIEW' object_type, substr(v.audit$, 1, 1) || '/' || substr(v.audit$, 2, 1) alt, substr(v.audit$, 3, 1) || '/' || substr(v.audit$, 4, 1) aud, substr(v.audit$, 5, 1) || '/' || substr(v.audit$, 6, 1) com, substr(v.audit$, 7, 1) || '/' || substr(v.audit$, 8, 1) del, substr(v.audit$, 9, 1) || '/' || substr(v.audit$, 10, 1) gra, substr(v.audit$, 11, 1) || '/' || substr(v.audit$, 12, 1) ind, substr(v.audit$, 13, 1) || '/' || substr(v.audit$, 14, 1) ins, substr(v.audit$, 15, 1) || '/' || substr(v.audit$, 16, 1) loc, substr(v.audit$, 17, 1) || '/' || substr(v.audit$, 18, 1) ren, substr(v.audit$, 19, 1) || '/' || substr(v.audit$, 20, 1) sel, substr(v.audit$, 21, 1) || '/' || substr(v.audit$, 22, 1) upd, '-/-' ref, /* dummy REF column */ substr(v.audit$, 25, 1) || '/' || substr(v.audit$, 26, 1) exe, substr(v.audit$, 27, 1) || '/' || substr(v.audit$, 28, 1) cre, substr(v.audit$, 29, 1) || '/' || substr(v.audit$, 30, 1) rea, substr(v.audit$, 31, 1) || '/' || substr(v.audit$, 32, 1) wri, substr(v.audit$, 23, 1) || '/' || substr(v.audit$, 24, 1) fbk from sys.obj$ o, sys.user$ u, sys.view$ v where o.type# = 4 and o.owner# = u.user# and (instrb(v.audit$,'S') != 0 or instrb(v.audit$,'A') != 0) and o.obj# = v.obj# union all select u.name owner, o.name object_name, 'SEQUENCE' object_type, substr(s.audit$, 1, 1) || '/' || substr(s.audit$, 2, 1) alt, substr(s.audit$, 3, 1) || '/' || substr(s.audit$, 4, 1) aud, substr(s.audit$, 5, 1) || '/' || substr(s.audit$, 6, 1) com, substr(s.audit$, 7, 1) || '/' || substr(s.audit$, 8, 1) del, substr(s.audit$, 9, 1) || '/' || substr(s.audit$, 10, 1) gra, substr(s.audit$, 11, 1) || '/' || substr(s.audit$, 12, 1) ind, substr(s.audit$, 13, 1) || '/' || substr(s.audit$, 14, 1) ins, substr(s.audit$, 15, 1) || '/' || substr(s.audit$, 16, 1) loc, substr(s.audit$, 17, 1) || '/' || substr(s.audit$, 18, 1) ren, substr(s.audit$, 19, 1) || '/' || substr(s.audit$, 20, 1) sel, substr(s.audit$, 21, 1) || '/' || substr(s.audit$, 22, 1) upd, '-/-' ref, /* dummy REF column */ substr(s.audit$, 25, 1) || '/' || substr(s.audit$, 26, 1) exe, substr(s.audit$, 27, 1) || '/' || substr(s.audit$, 28, 1) cre, substr(s.audit$, 29, 1) || '/' || substr(s.audit$, 30, 1) rea, substr(s.audit$, 31, 1) || '/' || substr(s.audit$, 32, 1) wri, substr(s.audit$, 23, 1) || '/' || substr(s.audit$, 24, 1) fbk from sys.obj$ o, sys.user$ u, sys.seq$ s where o.type# = 6 and o.owner# = u.user# and (instrb(s.audit$,'S') != 0 or instrb(s.audit$,'A') != 0) and o.obj# = s.obj# union all select u.name owner, o.name object_name, 'PROCEDURE' object_type, substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1) alt, substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1) aud, substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1) com, substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1) del, substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1) gra, substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1) ind, substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1) ins, substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1) loc, substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1) ren, substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1) sel, substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1) upd, '-/-' ref, /* dummy REF column */ substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1) exe, substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1) cre, substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1) rea, substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1) wri, substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1) fbk from sys.obj$ o, sys.user$ u, sys.library$ p where o.type# = 22 and o.owner# = u.user# and (instrb(p.audit$,'S') != 0 or instrb(p.audit$,'A') != 0) and o.obj# = p.obj# union all select u.name owner, o.name object_name, 'PROCEDURE' object_type, substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1) alt, substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1) aud, substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1) com, substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1) del, substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1) gra, substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1) ind, substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1) ins, substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1) loc, substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1) ren, substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1) sel, substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1) upd, '-/-' ref, /* dummy REF column */ substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1) exe, substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1) cre, substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1) rea, substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1) wri, substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1) fbk from sys.obj$ o, sys.user$ u, sys.procedure$ p where o.type# >= 7 and o.type# <= 9 and o.owner# = u.user# and (instrb(p.audit$,'S') != 0 or instrb(p.audit$,'A') != 0) and o.obj# = p.obj# union all select u.name owner, o.name object_name, 'TYPE' object_type, substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1) alt, substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1) aud, substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1) com, substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1) del, substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1) gra, substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1) ind, substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1) ins, substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1) loc, substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1) ren, substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1) sel, substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1) upd, '-/-' ref, /* dummy REF column */ substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1) exe, substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1) cre, substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1) rea, substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1) wri, substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1) fbk from sys.obj$ o, sys.user$ u, sys.type_misc$ t where o.type# = 13 and o.owner# = u.user# and (instrb(t.audit$,'S') != 0 or instrb(t.audit$,'A') != 0) and o.obj# = t.obj# union all select u.name owner, o.name object_name, 'DIRECTORY' object_type, substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1) alt, substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1) aud, substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1) com, substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1) del, substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1) gra, substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1) ind, substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1) ins, substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1) loc, substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1) ren, substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1) sel, substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1) upd, '-/-' ref, /* dummy REF column */ substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1) exe, substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1) cre, substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1) rea, substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1) wri, substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1) fbk
                  from sys.obj$ o, sys.user$ u, sys.dir$ t 
                  where o.type# = 23 and o.owner# = u.user# and (instrb(t.audit$,'S') != 0 or instrb(t.audit$,'A') != 0) and o.obj# = t.obj#)
            WHERE nvl(owner, '%') not like 'SYS') x,
      (SELECT rownum as rn FROM dual CONNECT BY level <= 17) d
     )
WHERE action_name is not null)
  loop
    begin
      execute immediate 'NOAUDIT ' || t.action_name || ' ON ' || t.owner || '.' || t.object_name;
    exception when others then
      null;
    end;
  end loop;
end;
/

AUDIT INSERT ON DEVEL.UNITLOGS BY ACCESS;
AUDIT SELECT ON DEVEL.UNITLOGS_ID BY ACCESS;
AUDIT SELECT ON DEVEL.UNITLOGS_TRANSACTION_ID BY ACCESS;
AUDIT EXECUTE ON DEVEL.GG_SEQUENCE BY ACCESS;

select * from (
select * from dba_audit_trail where owner = 'DEVEL' order by timestamp desc
)
where rownum <= 100;

select * from dba_audit_trail where action_name in ('INSERT', 'DELETE', 'UPDATE', 'SELECT') order by timestamp desc;


select * from dba_tab_privs where grantor = 'DEVEL' and table_name = 'UNITLOGS_ID';

select * from all_tab_privs where grantor = 'DEVEL' and table_name = 'UNITLOGS_ID';