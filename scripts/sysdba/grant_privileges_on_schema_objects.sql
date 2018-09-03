/*

Script to grant ALL/RO (read-only) or REVOKE privileges on db objects in defined schema to specified user
*/
set serveroutput on size 1000000 verify off timing off feedback off termout on echo off

define db_user='&1'
define db_owner='&2'
define mode='&3'

declare
  l_owner varchar2(32);
  l_user  varchar2(32);
  l_mode  varchar2(32);

  procedure exec_SQL(p_SQL varchar2)
  is
  begin
    dbms_output.put_line(p_SQL || ';');
    execute immediate p_SQL;
  exception when others then
    dbms_output.put_line(SQLERRM);
  end exec_SQL;
  
begin
  dbms_output.enable(null);

  l_owner := upper('&db_owner');
  l_user := upper('&db_user');
  l_mode := nvl(upper('&mode'), 'RO');

  for x in (select 'GRANT select, insert, update, delete ON "' || t.owner || '"."' || table_name || '" TO "' || l_user || '"' as grant_sql,
              'GRANT all ON "' || t.owner || '"."' || table_name || '" TO "' || l_user || '"' as grant_all_sql,
              'GRANT select ON "' || t.owner || '"."' || table_name || '" TO "' || l_user || '"' as grant_select_sql,
              'REVOKE all ON "' || t.owner || '"."' || table_name || '" FROM "' || l_user || '"' as revoke_sql,
              table_name,
              TEMPORARY,
              (select count(*) from dba_tab_privs p where p.owner = t.owner and grantee = l_user and p.table_name = t.table_name) as is_exists
            from dba_tables t
            where t.owner = l_owner) loop
    if (l_mode = 'REVOKE' AND x.is_exists > 0) OR (l_mode = 'ALL') OR (l_mode = 'RW' AND x.is_exists < 3) OR (l_mode = 'RO' AND x.is_exists = 0) then
      case l_mode
        when 'RO' then
          if nvl(x.TEMPORARY, 'N') = 'Y' then
            exec_SQL(x.grant_sql);
          else
            exec_SQL(x.grant_select_sql);
          end if;
        when 'RW' then
          exec_SQL(x.grant_sql);
        when 'ALL' then
          exec_SQL(x.grant_all_sql);
        when 'REVOKE' then
          exec_SQL(x.revoke_sql);
      end case;
    end if;
  end loop;

  for x in (select 'GRANT select ON "' || t.owner || '"."' || t.object_name || '" TO "' || l_user || '"' as grant_select_sql,
              'GRANT all ON "' || t.owner || '"."' || t.object_name || '" TO "' || l_user || '"' as grant_all_sql,
              'GRANT select, insert, update, delete ON "' || t.owner || '"."' || t.object_name || '" TO "' || l_user || '"' as grant_sql,
              'REVOKE all ON "' || t.owner || '"."' || t.object_name || '" FROM "' || l_user || '"' as revoke_sql,
              (select count(trigger_name) from dba_triggers s where s.owner = t.owner AND s.table_name = t.object_name and s.trigger_type = 'INSTEAD OF') as triggers_count,
	            (select count(*) from dba_tab_privs p where p.owner = t.owner AND p.grantee = l_user AND p.table_name = t.object_name) as is_exists
            FROM dba_objects t
            WHERE t.owner = l_owner AND object_type IN ('VIEW', 'MATERIALIZED VIEW')) loop
    if (l_mode = 'ALL')
      OR (l_mode = 'REVOKE' AND x.is_exists > 0)
      OR (l_mode = 'RO' AND x.is_exists = 0)
      OR (l_mode = 'RW' AND ((x.triggers_count = 0 AND x.is_exists = 0) OR (x.triggers_count > 0 AND x.is_exists < 3))) then
      case l_mode
        when 'RO' then
          exec_SQL(x.grant_select_sql);
        when 'RW' then
          if x.triggers_count = 0 then
            exec_SQL(x.grant_select_sql);
          else
            exec_SQL(x.grant_sql);
          end if;
        when 'ALL' then
          exec_SQL(x.grant_all_sql);
        when 'REVOKE' then
          exec_SQL(x.revoke_sql);
      end case;
    end if;
  end loop;
  
  for x in (select distinct 'GRANT execute ON "' || t.owner || '"."' || object_name || '" TO "' || l_user || '"' as grant_sql,
              'GRANT all ON "' || t.owner || '"."' || object_name || '" TO "' || l_user || '"' as grant_all_sql,
              'REVOKE execute ON "' || t.owner || '"."' || object_name || '" FROM "' || l_user || '"' as revoke_sql,
              (select count(*) from dba_tab_privs p where p.owner = t.owner AND p.grantee = l_user and p.table_name = t.object_name) as is_exists
            from dba_procedures t
            where t.owner = l_owner AND t.object_type in ('PROCEDURE', 'FUNCTION', 'PACKAGE')) loop
    if l_mode = 'REVOKE' AND x.is_exists > 0 then
      exec_SQL(x.revoke_sql);
    elsif l_mode IN ('RW', 'RO') AND x.is_exists = 0 then
      exec_SQL(x.grant_sql);
    elsif l_mode = 'ALL' then
      exec_SQL(x.grant_all_sql);
    end if;
  end loop;

  for x in (select distinct 'GRANT execute ON "' || t.owner || '"."' || type_name || '" TO "' || l_user || '"' as grant_sql,
              'GRANT all ON "' || t.owner || '"."' || type_name || '" TO "' || l_user || '"' as grant_all_sql,
              'REVOKE execute ON "' || t.owner || '"."' || type_name || '" FROM "' || l_user || '"' as revoke_sql,
              (select count(*) from dba_tab_privs p where p.owner = t.owner AND p.grantee = l_user and p.table_name = t.type_name) as is_exists
            from dba_types t
            where t.owner = l_owner) loop
    if l_mode = 'REVOKE' AND x.is_exists > 0 then
      exec_SQL(x.revoke_sql);
    elsif l_mode IN ('RW', 'RO') AND x.is_exists = 0 then
      exec_SQL(x.grant_sql);
    elsif l_mode = 'ALL' then
      exec_SQL(x.grant_all_sql);
    end if;
  end loop;

  for x in (select 'GRANT select ON "' || t.sequence_owner || '"."' || sequence_name || '" TO "' || l_user || '"' as grant_sql,
              'GRANT all ON "' || t.sequence_owner || '"."' || sequence_name || '" TO "' || l_user || '"' as grant_all_sql,
              'REVOKE all ON "' || t.sequence_owner || '"."' || sequence_name || '" FROM "' || l_user || '"' as revoke_sql,
	            (select count(*) from dba_tab_privs p where p.owner = t.sequence_owner AND p.grantee = l_user and p.table_name = t.sequence_name) as is_exists
            from dba_sequences t
            where t.sequence_owner = l_owner) loop
    if l_mode = 'REVOKE' AND x.is_exists > 0 then
      exec_SQL(x.revoke_sql);
    elsif l_mode IN ('RW', 'RO') AND x.is_exists = 0 then
      exec_SQL(x.grant_sql);
    elsif l_mode = 'ALL' then
      exec_SQL(x.grant_all_sql);
    end if;
  end loop;
end;
/
set echo on
