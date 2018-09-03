ALTER SYSTEM RESET sec_case_sensitive_logon SCOPE=SPFILE SID='*';
ALTER SYSTEM SET sec_case_sensitive_logon=TRUE SCOPE=MEMORY SID='*';
