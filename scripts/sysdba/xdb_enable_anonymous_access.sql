/*

How To Configure XDB Not To Prompt For User And Password (Doc ID 409082.1)
*/
-- enable anonymous access to XDB repository 

SET SERVEROUTPUT ON 
DECLARE 
  l_cfgxml XMLTYPE; 
  l_value VARCHAR2(5) := 'true'; -- (true/false) 
BEGIN 
  l_cfgxml := DBMS_XDB.cfg_get(); 

  IF l_cfgxml.existsNode('/xdbconfig/sysconfig/protocolconfig/httpconfig/allow-repository-anonymous-access') = 0 THEN 
  -- Add missing element. 
    SELECT insertChildXML(l_cfgxml, 
      '/xdbconfig/sysconfig/protocolconfig/httpconfig', 
      'allow-repository-anonymous-access', 
      XMLType('<allow-repository-anonymous-access xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">' || l_value || '</allow-repository-anonymous-access>'), 
      'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') 
    INTO l_cfgxml 
    FROM dual; 
    DBMS_OUTPUT.put_line('Element inserted.'); 
  ELSE 
  -- Update existing element. 
    SELECT updateXML(DBMS_XDB.cfg_get(), 
      '/xdbconfig/sysconfig/protocolconfig/httpconfig/allow-repository-anonymous-access/text()', 
      l_value, 
      'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') 
    INTO l_cfgxml 
    FROM dual; 

    DBMS_OUTPUT.put_line('Element updated.'); 
  END IF; 

  DBMS_XDB.cfg_update(l_cfgxml); 
  DBMS_XDB.cfg_refresh; 
END; 
/
