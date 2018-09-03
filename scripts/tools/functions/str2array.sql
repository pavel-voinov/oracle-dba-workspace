/*
*/
CREATE OR REPLACE FUNCTION str2array (
  p_String varchar2,
  p_Delimiter varchar2 default ',',
  p_ElementsCount integer default null,
  p_OptionallyEnclosed varchar2 default '"')
  return TStrings
as
  l_regexp varchar2(255);
  l_str    VARCHAR2(32000);
  i        NUMBER;
  l_result TStrings;
  l_encl1 varchar2(2);
  l_encl2 varchar2(2);
  l_encl varchar2(4);
  l_delimiter varchar2(10);

begin
  -- prepare delimiter
  l_delimiter := nvl(substr(p_Delimiter, 1, 10), ' ');
  if l_delimiter = ' ' then
    l_delimiter := '[:space:]';
  else
    l_delimiter := '\' || l_delimiter;
  end if;
  l_regexp := '[^' || l_delimiter || ']+';

  -- prepare open- and close- symbols for phrase and fixes final regexp
  if p_OptionallyEnclosed is not null then
    l_encl1 := substr(p_OptionallyEnclosed, 1, 1);
    l_encl2 := '\' || nvl(substr(p_OptionallyEnclosed, 2, 1), l_encl1);
    l_encl1 := '\' || l_encl1;
    if l_encl1 = l_encl2 then
      l_encl := l_encl1;
    else
      l_encl := l_encl1 || l_encl2;
    end if;
    l_regexp := '(' || l_encl1 || '[^' || l_encl || ']+' || l_encl2 || ')|(' || l_regexp || ')';
  end if;

  l_result := TStrings();
  i := 1;
  loop
    l_str := regexp_substr(p_String, l_regexp, 1, i);
    exit when l_str is null;
    l_result.extend();
    l_result(i) := l_str;
    i := i + 1;
  end loop;

  if nvl(p_elementscount, 0) > l_result.count then
    l_result.extend(nvl(p_elementscount, 0) - l_result.count);
  end if;

  return l_result;
end str2array;
/
GRANT EXECUTE ON str2array TO PUBLIC;
