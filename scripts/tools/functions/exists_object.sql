/*
*/
CREATE OR REPLACE FUNCTION exists_object (
  p_ObjectName varchar2,
  p_ObjectType varchar2 default 'TABLE',
  p_Schema     varchar2 default null)
  return integer
as
  l_result integer;
begin
  DBMS_APPLICATION_INFO.SET_MODULE('TOOLS', 'exists_object');

  SELECT count(*) INTO l_result
  FROM all_objects
  WHERE owner = nvl(upper(p_Schema), sys_context('USERENV', 'CURRENT_SCHEMA'))
    AND object_type = upper(p_ObjectType)
    AND object_name = upper(p_ObjectName);

  DBMS_APPLICATION_INFO.SET_MODULE(null, null);

  return sign(l_result);
end exists_object;
/
GRANT EXECUTE ON exists_object TO PUBLIC;