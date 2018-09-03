CREATE OR REPLACE FUNCTION "SYS"."MD5_C" (
  p in clob)
  return varchar2
  deterministic
is
  l_hash raw(4000);
begin
  if p is null then
    return null;
  end if;
  l_hash := lower(dbms_crypto.hash(src => p, typ => dbms_crypto.HASH_MD5));
  return l_hash;
end;
/
create or replace public synonym md5_c for sys.md5_c
/
grant execute on sys.md5_c to public
/
