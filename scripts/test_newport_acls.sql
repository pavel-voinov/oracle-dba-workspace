set serveroutput on size unlimited

DECLARE
  ldap_host tpharma_user.ldap_constants.ldap_host%TYPE;
  ldap_port tpharma_user.ldap_constants.ldap_port%TYPE;

  CURSOR c_ldap_constants IS
    SELECT ldap_host, ldap_port
    FROM tpharma_user.ldap_constants;

  ldap_session DBMS_LDAP.SESSION;
BEGIN
  OPEN c_ldap_constants;
  FETCH c_ldap_constants INTO ldap_host, ldap_port;
  CLOSE c_ldap_constants;

  dbms_output.enable(null);
  dbms_output.put_line('ldap_host:ldap_port = ' || ldap_host || ':' || ldap_port);

  ldap_session := DBMS_LDAP.init(ldap_host, ldap_port);
END;
/
