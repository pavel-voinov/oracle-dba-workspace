set serveroutput on size unlimited buffer 100000 verify off timing off feedback off scan on

/*

This script shows information for dump
*/

ACCEPT p_dir PROMPT "Enter Oracle directory name to place dump files. [DATA_PUMP_DIR]: "
ACCEPT p_dump PROMPT "Enter dump file(s) mask: "

set term off

column p_dir new_value p_dir
column p_dump new_value p_dump

SELECT nvl(upper('&p_dir'), 'DATA_PUMP_DIR') as p_dir FROM dual
/

set term on

PROMPT
PROMPT ===============================================
PROMPT You have selected:
PROMPT ===============================================
PROMPT Directory: &p_dir
PROMPT Dump mask: &p_dump
PROMPT

pause Press any key to show dump info or Ctrl-C to cancel further operations

declare
  l_handle   integer;
  l_dir      varchar2(30) := '&p_dir';
  l_dump     varchar2(255) := '&p_dump';
  l_DumpInfo KU$_DUMPFILE_INFO;
  l_FileType number;
begin
  dbms_datapump.get_dumpfile_info(filename => l_dump, directory => l_dir, info_table => l_DumpInfo, filetype => l_FileType);
   
  --0 - not a valid dumpfile
  --1 - datapump dumpfile
  --2 - original export dumpfile
  if l_FileType <> 1 then
    raise_application_error(-20001, 'Dumpfile ' || l_dump || ' in ' || l_dir || ' is not a datapump valid file');
  end if;

  dbms_output.enable(null);   
  dbms_output.put_line('FILE_VERSION: '        || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_FILE_VERSION).Value);
  dbms_output.put_line('MASTER_PRESENT: '      || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_MASTER_PRESENT).Value);
  dbms_output.put_line('GUID: '                || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_GUID).Value);
  dbms_output.put_line('FILE_NUMBER: '         || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_FILE_NUMBER).Value);
  dbms_output.put_line('CHARSET_ID: '          || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_CHARSET_ID).Value);
  dbms_output.put_line('CREATION_DATE: '       || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_CREATION_DATE).Value);
  dbms_output.put_line('FLAGS: '               || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_FLAGS).Value);
  dbms_output.put_line('JOB_NAME: '            || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_JOB_NAME).Value);
  dbms_output.put_line('PLATFORM: '            || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_PLATFORM).Value);
  dbms_output.put_line('INSTANCE: '            || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_INSTANCE).Value);
  dbms_output.put_line('LANGUAGE: '            || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_LANGUAGE).Value);
  dbms_output.put_line('BLOCKSIZE: '           || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_BLOCKSIZE).Value);
  dbms_output.put_line('DIRPATH: '             || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_DIRPATH).Value);
  dbms_output.put_line('METADATA_COMPRESSED: ' || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_METADATA_COMPRESSED).Value);
  dbms_output.put_line('DB_VERSION: '          || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_DB_VERSION).Value);
--  dbms_output.put_line('MAX_ITEM_CODE: '       || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_MAX_ITEM_CODE).Value);
  dbms_output.put_line('MASTER_PIECE_COUNT: '  || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_MASTER_PIECE_COUNT).Value);
  dbms_output.put_line('MASTER_PIECE_NUMBER: ' || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_MASTER_PIECE_NUMBER).Value);
  dbms_output.put_line('DATA_COMPRESSED: '     || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_DATA_COMPRESSED).Value);
  dbms_output.put_line('METADATA_ENCRYPTED: '  || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_METADATA_ENCRYPTED).Value);
--  dbms_output.put_line('DATA_ENCRYPTED: '      || l_DumpInfo(DBMS_DATAPUMP.KU$_DFHDR_DATA_ENCRYPTED).Value);
end;
/

set timing on feedback on
