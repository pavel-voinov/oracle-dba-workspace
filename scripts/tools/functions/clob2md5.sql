/*
*/
CREATE OR REPLACE FUNCTION "BARSTRMADM"."CLOB2MD5" (
  p_clob in clob)
  return varchar2 deterministic
as
  l_hash raw(4000);
begin
  if p_clob is null then
    return null;
  end if;
  l_hash := dbms_crypto.hash(src => p_clob, typ => dbms_crypto.hash_md5);
  return l_hash;
end clob2md5;
/
