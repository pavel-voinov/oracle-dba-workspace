select c.value || '/' || instance || '_ora_' ||
       ltrim(to_char(a.spid,'fm99999')) || '.trc'
  from v$process a, v$session b, v$parameter c, v$thread c
 where a.addr = b.paddr
   and b.audsid = userenv('sessionid')
   and c.name = 'user_dump_dest';
   
create user trace_files identified by trace_files default tablespace users quota 
unlimited on users;

grant create any directory, /* to read user dump dest */
      create session,  /* to log on in the first place */
      create table,    /* used to hold users -> trace files */
      create view,     /* used so users can see what traces they have */
      create procedure, /* to create the function that returns the trace data */
      create trigger,  /* to capture trace file names upon logoff */
      administer database trigger, /* to create the logoff trigger */
      create synonym
to trace_files;

/* these are needed to find the trace file name */
grant select on v_$process to trace_files;
grant select on v_$session to trace_files;
grant select on v_$instance to trace_files;
grant select on v_$parameter to trace_files;


in that user, you will execute:

alter session set current_schema=SYS;
alter session set current_schema=TRACE_FILES;
alter session set tracefile_identifier='';

create view session_trace_file_names_v
as
select d.instance_name || '_ora_' || ltrim(to_char(a.spid)) || decode(p.value, null, '', '_' || p.value) || '.trc' as filename
from v$process a, v$session b, v$instance d, v$parameter p
where a.addr = b.paddr and b.audsid = userenv('SESSIONID') and p.name = 'tracefile_identifier'
/

create table available_trace_files (
  username varchar2(30) default user,
  filename varchar2(512),
  dt       timestamp(6) default systimestamp,
  constraint available_trace_files_pk primary key (username, filename)
) organization index
/

create or replace view user_available_trace_files_v
as
select * 
from available_trace_files
where nvl(username, user) = user;

grant select on user_available_trace_files_v to public;

create global temporary table trace_files_text (
  id integer,
  text varchar2(4000),
  constraint trace_files_text_pk primary key (id)
);
grant select on trace_files_text to public
/

create or replace public synonym dba_available_trace_files for trace_files.available_trace_files;
create or replace public synonym user_available_trace_files for trace_files.user_available_trace_files;
create or replace synonym user_available_trace_files for user_available_trace_files_v;
create or replace synonym session_trace_file_names for session_trace_file_names_v;

create or replace trigger capture_trace_files
before logoff on database
begin
  for x in (select * from trace_files.session_trace_file_names_v)
  loop
    if dbms_lob.fileexists(bfilename('USER_DUMP_DEST', x.filename)) = 1 then
      insert into trace_files.available_trace_files (filename) values (x.filename);
    end if;
  end loop;
end;
/

create or replace procedure trace_file_contents(p_filename in varchar2)
as
  l_bfile   bfile := bfilename('USER_DUMP_DEST', p_filename);
  l_last    number := 1;
  l_current number;
begin
  select rownum into l_current
  from  trace_files.user_available_trace_files_v
  where filename = p_filename;

  delete from trace_files_text;
  dbms_lob.fileopen(l_bfile);
  loop
    l_current := dbms_lob.instr(l_bfile, '0A', l_last, 1);
    exit when (nvl(l_current,0) = 0);

    insert into trace_files_text (id,text)
    values (l_last, utl_raw.cast_to_varchar2(dbms_lob.substr(l_bfile, l_current - l_last + 1, l_last)));
    l_last := l_current+1;
  end loop;
  dbms_lob.fileclose(l_bfile);
end;
/
grant execute on trace_file_contents to public
/


select filename from trace_files.user_available_trace_files_v;