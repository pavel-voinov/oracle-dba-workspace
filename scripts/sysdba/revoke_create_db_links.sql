set serveroutput on echo off verify off timing off feedback off

begin
  dbms_output.enable(null);
  for t in (SELECT u.username, p.privilege
            FROM dba_users u, dba_sys_privs p
            WHERE u.username = p.grantee
              AND regexp_like(p.privilege, '(CREATE|DROP).* DATABASE LINK')
              AND not regexp_like(u.username, '^(SYS|PUBLIC|XS\$NULL|GGS|.*_RO)$'))
  loop
    dbms_output.put_line('REVOKE ' || t.privilege || ' FROM "' || t.username || '";');
    execute immediate 'REVOKE ' || t.privilege || ' FROM "' || t.username || '"';
  end loop;
end;
/
