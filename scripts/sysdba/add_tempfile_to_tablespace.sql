/*

Script to add tempfile(s) to tablespace in ASM diskgroups/NAS storage/LION stanardized environments with required number of autoextended files

Usage: @add_tempfile_to_tablespace.sql <tablespace name> <base directory/diskgroup for datafiles|default|null|*|none|any> <number of tempfiles to create>

*/
set serveroutput on size unlimited echo off verify off

define ts_name=&1
define dir_name=&2
define files_count=&3

declare
  l_cnt         integer := to_number(nvl(trim('&files_count'), 1));
  l_SQL         varchar2(32000);
  l_dir         varchar2(512) := '&dir_name';
  l_default_dir varchar2(512);
  l_ts          varchar2(30) := upper('&ts_name');
  l_tmp         varchar2(512);
  i             integer;
  l_last_number integer;
  is_asm        boolean;
  is_lion       boolean;
  l_df_prefix   varchar2(30);
begin
  dbms_output.enable(null);

  SELECT count(*) INTO i FROM v$tablespace WHERE name = l_ts;
  if i = 0 then
    raise_application_error(-20001, 'Tablespace "' || l_ts || '" does not exist');
  end if;

  if trim(lower(l_dir)) in ('null', '*', 'any', 'none', '') then
    l_dir := null;
  elsif trim(lower(l_dir)) = 'default' then
    SELECT value INTO l_default_dir
    FROM v$parameter
    WHERE name = 'db_create_file_dest';

    l_dir := null;
  end if;
  l_dir := regexp_replace(l_dir, '\/*$');

  SELECT count(*) into i
  FROM v$asm_diskgroup;
  is_asm := i > 0;

  SELECT count(*) INTO i
  FROM v$tempfile d, v$tablespace t
  WHERE t.name = l_ts
    AND t.ts# = d.ts#
    AND regexp_like(d.name, '^/(n|s)[0-9]{2}/oradata[0-9]{1}/');
  is_lion := i > 0;
  l_last_number := i;

  if l_dir is null and is_lion then
    SELECT regexp_replace(name, '^(.*)\/(.*).dbf', '\1') INTO l_default_dir
    FROM v$tempfile
    WHERE rownum = 1;
  end if;

  if l_dir is null and l_default_dir is null then
    raise_application_error(-20002, 'Destination for datafiles is not set neither by database parameter nor by script parameter');
  end if;

  if is_lion then
    l_df_prefix := regexp_replace(lower(sys_context('USERENV', 'DB_UNIQUE_NAME')), '[a-z]{1}$') || '_';
  else
    l_df_prefix := lower(sys_context('USERENV', 'DB_UNIQUE_NAME')) || '_';
  end if;

  l_SQL := 'ALTER TABLESPACE "' || l_ts || '" ADD TEMPFILE';
  i := 1;
  while i <= l_cnt
  loop
    if i > 1 then
      l_SQL := l_SQL || ',';
    end if;
    if is_lion then
      l_SQL := l_SQL || ' ''' || nvl(l_dir, l_default_dir) || '/' || l_df_prefix || lower(l_ts) || lpad(i + l_last_number, 2, '0') || '.dbf'' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
    else
      if l_dir is null then -- it means that l_default_dir is not null and it's set by database parameter
        l_SQL := l_SQL || ' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
      else
        if is_asm and regexp_like(l_dir, '^\+[A-Z0-9_]+$') then
          l_SQL := l_SQL || ' ''' || l_dir || ''' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
        else
          l_SQL := l_SQL || ' ''' || l_dir || '/' || l_df_prefix || lower(l_ts) || lpad(i, 2, '0') || '.dbf'' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
        end if;
      end if;
    end if;
    i := i + 1;
  end loop;
  begin
    dbms_output.put_line(l_SQL);
    execute immediate l_SQL;
  exception when others then
    dbms_output.put_line(SQLERRM);
  end;
exception when others then
  dbms_output.put_line(SQLERRM);
end;
/
