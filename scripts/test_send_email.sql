declare
  v_mail_conn utl_smtp.connection;
  v_email_message varchar2(32000);
  cr varchar2(4) := utl_tcp.crlf;
  v_mail_host varchar2(255) := 'localhost';
  v_sender varchar2(255) := 'ghost-dba@yandex.ru';
  v_recipient varchar2(255) := 'ghost-dba@yandex.ru';

begin
  v_mail_conn := utl_smtp.open_connection(v_mail_host);
  
  utl_smtp.helo(v_mail_conn, v_mail_host);
  utl_smtp.mail(v_mail_conn, v_sender);
  utl_smtp.rcpt(v_mail_conn, v_recipient);
  
  v_email_message := 'Subject: Test message' || cr;
  v_email_message := v_email_message || 'From: '|| v_sender || cr;
  v_email_message := v_email_message || 'To: '|| v_recipient || cr;
  v_email_message := v_email_message || 'Date: '|| TO_CHAR(SYSDATE, 'DD Mon YYYY HH24:MI:SS') || cr;
  v_email_message := v_email_message || '' || cr;
  v_email_message := v_email_message || 'User: ' || sys_context('USERENV', 'CURRENT_USER') || cr;
  v_email_message := v_email_message || '  DB: ' || sys_context('USERENV', 'DB_NAME') || cr;
  v_email_message := v_email_message || 'Host: ' || sys_context('USERENV', 'SERVER_HOST') || cr;
  v_email_message := v_email_message || '' || cr;
  
  utl_smtp.data(v_mail_conn, v_email_message);
  utl_smtp.quit(v_mail_conn);
end;
/  
