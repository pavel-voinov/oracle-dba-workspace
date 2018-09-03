use strict;
use File::Copy;
use File::Basename;
use Sys::Hostname;
use Socket;
my $LWPfound=1;
eval "use LWP::UserAgent";
if ($@) {
  $LWPfound=0;
}

$|=1;

my $cmdOption='';
my $argcnt=$#ARGV + 1;
if ($argcnt == 0){
  $cmdOption="-collect";
} elsif (($argcnt != 1) || (lc($ARGV[0]) ne "-dbgon") &&
                      (lc($ARGV[0]) ne "-dbgoff") &&
                      (lc($ARGV[0]) ne "-collect")) {
  printf("Usage: perl $0 [-dbgon | -dbgoff | -collect]\n");
  exit 1;
} else {
  $cmdOption=lc($ARGV[0]);
}

#####
# Ask for ORACLE_HOME directory
#####
my $oh=$ENV{'ORACLE_HOME'};
print "Enter the ORACLE_HOME path [$oh]: ";
my $oraclehome=<STDIN>;
chomp($oraclehome);
if ($oraclehome eq "") {
  $oraclehome=$oh;
}
$oraclehome=~tr/\\/\//;
if ((! -d "$oraclehome/bin") ||
    (! -d "$oraclehome/Apache") ||
    (! -d "$oraclehome/rdbms")) {
  printf("\nInvalid ORACLE_HOME directory specified.\n");
  printf("Check to make sure that $oraclehome is the correct\n");
  printf("value for your ORACLE_HOME and try again.\n\n");
  exit(1);
}

#####
# Get SYSTEM password
#####
print "Enter the password for the SYSTEM account: ";
system("stty -echo") if ($^O !~ /win/i);
my $systempwd=<STDIN>;
chomp($systempwd);
if ($^O !~ /win/i) {
  system("stty echo");
  print "\n";
}

my $oidpasswd='';
print "Enter the password for the OID cn=orcladmin user: ";
system("stty -echo") if ($^O !~ /win/i);
$oidpasswd=<STDIN>;
chomp($oidpasswd);
if ($^O !~ /win/i) {
  system("stty echo");
  print "\n";
}


#####
# Ask for filename to write debug output to
#####
my $outputfile='';
if (($cmdOption eq "-dbgoff") ||
    ($cmdOption eq "-collect")){
  print "Enter the output filename [ssodbg.zip]: ";
  $outputfile=<STDIN>;
  chomp ($outputfile);
  if ($outputfile eq "") {
    $outputfile="ssodbg";
  }
  if ($outputfile =~ /\.zip$/i) {
    $outputfile=substr $outputfile, 0, -4;
  }
  if (-e "$outputfile.zip") {
    printf("\nThe output file $outputfile.zip already exists.\n");
    printf("Remove or rename the $outputfile.zip file and try again.\n\n");
    exit(1);
  }
}

#####
# Validate SYSTEM password
#####
printf("\nVerifying SYSTEM password...\n");
my $status=verifyDatabasePassword("system", $systempwd);
if ($status) {
  printf("\nInvalid SYSTEM schema password.\n");
  printf("Check entered schema password and connect string ");
  printf("and try again.\n\n");
  printf("Note: If the metadata repository is on a differnt machine from\n");
  printf("where this script is run from you MUST supply a TNS connect string\n");
  printf("with the SYSTEM password. The format is 'password\@TNSalias' where\n");
  printf("TNSalias is an entry from the tnsnames.ora file that references the\n");
  printf("metadata repository.\n\n");
  exit(1);
}

#####
# Validate the OID password
#####
my $oidhost='';
my $oidport='';
my $oiduser='';
my $oidpwd='';
my $ssl='';
my $cmdout='';
printf("Verifying the OID cn=orcladmin password...\n");
createSsoOidSqlFile();
system("$oraclehome/bin/sqlplus -s system/$systempwd \@ssooid.sql");
($oidhost, $oidport, $oiduser, $oidpwd, $ssl)=parseSsooconfFile();
$cmdout=`$oraclehome/bin/ldapbind -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl 2>&1`;
unlink "ssooid.sql";
unlink "ssooconf.txt";
if ($cmdout !~ /successful/i) {
  #printf("\nInvalid OID password for cn=orcladmin \n");
  #printf("Check the entered OID password and try again.\n\n");
  #exit(1);
  printf("\nWARNING: Unable to validate the password for the cn=orcladmin user.\n");
  printf("Continuing to run the script but the info in the oidconfig.txt\n");
  printf("will be incorrect. Additionally it will not be possible to enable\n");
  printf("or disable OID debugging using the -dbgon and -dbgoff parameters.\n");
}

#####
# Define file locations
#####
my $policyproperties="$oraclehome/sso/conf/policy.properties";
my $httpdconf="$oraclehome/Apache/Apache/conf/httpd.conf";
my $sslconf="$oraclehome/Apache/Apache/conf/ssl.conf";
my $opmnxml="$oraclehome/opmn/conf/opmn.xml";
my $modossoconf="$oraclehome/Apache/Apache/conf/mod_osso.conf";
my $dadsconf="$oraclehome/Apache/modplsql/conf/dads.conf";
my $targetsxml="$oraclehome/sysman/emd/targets.xml";

#####
# Define arrays to hold categories of files for web page
#####
my @httparr=();
my @ssoarr=();
my @wnaarr=();
my @iasarr=();
my @osarr=();
my @oidarr=();
my @webcachearr=();

#####
# Define log/config files to add to the zip file
#####
my @filelist=();
pushfile($httpdconf, "httparr");
pushfile($sslconf, "httparr");
pushfile("$oraclehome/Apache/Apache/conf/oracle_apache.conf", "httparr");
pushfile("$oraclehome/Apache/Apache/conf/mod_oc4j.conf", "httparr");
pushfile("$oraclehome/Apache/Apache/conf/mod_proxy.conf", "httparr");
pushfile($modossoconf, "httparr");
pushfile($policyproperties, "ssoarr");
pushfile("$oraclehome/sso/conf/sso_apache.conf", "httparr");
pushfile($dadsconf, "httparr");
pushfile("$oraclehome/j2ee/OC4J_SECURITY/config/jazn.xml", "wnaarr");
pushfile("$oraclehome/j2ee/OC4J_SECURITY/config/jazn-data.xml", "wnaarr");
pushfile("$oraclehome/opmn/conf/opmn.xml", "wnaarr");
pushfile("$oraclehome/j2ee/OC4J_SECURITY/log/OC4J_SECURITY_default_island_1/server.log", "wnaarr");
pushfile("$oraclehome/j2ee/OC4J_SECURITY/application-deployments/sso/orion-application.xml", "wnaarr");
pushfile("$oraclehome/j2ee/OC4J_SECURITY/application-deployments/sso/web/orion-web.xml", "ssoarr");
pushfile("$oraclehome/j2ee/OC4J_SECURITY/applications/sso/web/WEB-INF/web.xml", "wnaarr");
pushfile("$oraclehome/config/ias.properties", "iasarr");
pushfile("$oraclehome/sso/log/ssoServer.log", "ssoarr");
pushfile("$oraclehome/Apache/Apache/logs/" . getLastFile("$oraclehome/Apache/Apache/logs", "error_log."), "httparr");
pushfile("$oraclehome/Apache/Apache/logs/" . getLastFile("$oraclehome/Apache/Apache/logs", "access_log."), "httparr");
pushfile("$oraclehome/Apache/Apache/logs/access_log", "httparr");
pushfile("$oraclehome/Apache/Apache/logs/error_log", "httparr");
pushfile("$oraclehome/Apache/Apache/logs/ssl_engine_log", "httparr");
pushfile("$oraclehome/Apache/Apache/logs/ssl_request_log", "httparr");
pushfile("$oraclehome/opmn/logs/OC4J~OC4J_SECURITY~default_island~1", "ssoarr");
pushfile("$oraclehome/ldap/log/" . getLastFile("$oraclehome/ldap/log/", "oidldapd"), "oidarr");
pushfile("$oraclehome/sso/log/ssoreg.log", "ssoarr");
pushfile("$oraclehome/sso/log/ssoreg.err", "ssoarr");
pushfile("$oraclehome/sso/conf/X509CertAuth.properties", "ssoarr");
pushfile("$oraclehome/sysman/emd/targets.xml", "ssoarr");
pushfile("$oraclehome/webcache/webcache.xml", "webcachearr");
pushfile("$oraclehome/webcache/logs/event_log", "webcachearr");
pushfile("$oraclehome/webcache/logs/access_log", "webcachearr");
if ($^O =~ /win/i){
  if (-e "c:/winnt/krb5.ini"){
    pushfile("c:/winnt/krb5.ini", "wnaar");
  } else {
    pushfile("c:/windows/krb5.ini", "wnaarr");
  }
  if (-e "c:/winnt/system32/drivers/etc/hosts"){
    pushfile("c:/winnt/system32/drivers/etc/hosts", "osarr");
  } else {
    pushfile("c:/windows/system32/drivers/etc/hosts", "osarr");
  }
} else {
  if (-e "/etc/krb5.conf"){
    pushfile("/etc/krb5.conf", "wnaarr");
  } else {
    pushfile("/etc/krb5/krb5.conf", "wnaarr");
  }
  pushfile("/etc/hosts", "osarr");
}

#####
# Main body of script
#####
if ($cmdOption eq "-dbgon"){
  dbgOn();
} elsif ($cmdOption eq "-dbgoff"){
  dbgOff();
  collect();
} elsif ($cmdOption eq "-collect"){
  collect();
}

#####
# Enable debug mode for SSO, JAZN, OID and HTTP server 
#####
sub dbgOn() {
  #####
  # Check to see if debug is already enabled
  #####
  if (-e "$oraclehome/sso/conf/sso.dbg") {
    printf("\nCannot enable debugging. If debug mode has already ");
    printf("been enabled then run\n'perl $0 -dbgoff' to disable debug mode. If ");
    printf("this fails then you will\nneed to manually remove the ");
    printf("$oraclehome/sso/conf/sso.dbg\nfile and try again.\n");
    exit 1;
  } else {
    open (F, "> $oraclehome/sso/conf/sso.dbg");
    print F "Debug enabled at " . today() || "\n";
    close (F);
  }

  #####
  # Stop running processes
  #####
  stopProcs();

  #####
  # Enable debugging for policy.properties
  #####
  my $out='';
  if (-e $policyproperties) {
    printf("\nConfiguring debug directives in $policyproperties...\n");
    copy ($policyproperties, $policyproperties . "~ssodbg");
    open (F, "+< $policyproperties");   
    $out='';
    while (<F>) {
      if ($_ =~ /debugLevel\s*=/i) {
        $out .= "debugLevel=DEBUG\n";
      } else {
        $out .= $_;
      }
    }
    seek (F, 0, 0);
    print F $out;
    truncate (F, tell(F));
    close (F);
  }

  #####
  # Enable debugging for httpd.conf
  #####
  if (-e $httpdconf) {
    printf("Configuring debug directives in $httpdconf...\n");
    copy ($httpdconf, $httpdconf . "~ssodbg");
    open (F, "+< $httpdconf");
    $out='';
    while (<F>) {
      if ($_ =~ /LogLevel\s*[debug|info|notice|warn|error|crit|alert|emerg]/i) {
        $out .= "LogLevel debug\n";
      } else {
        $out .= $_;
      }
    }
    seek (F, 0, 0);
    # Bug on my linux box - if I enabled httpd debugging then I cannot
    # get it to restart without killing the processes. Therefore only
    # setup httpd debugging on other machines.
    if (hostname() ne "mlc2.acme.org") {
      print F $out;
      truncate (F, tell(F));
    }
    close (F);
  }  

  #####
  # Enable debugging for ssl.conf
  #####
  if (-e $sslconf) {
    printf("Configuring debug directives in $sslconf...\n");
    copy ($sslconf, $sslconf . "~ssodbg");
    open (F, "+< $sslconf");
    $out='';
    while (<F>) {
      if ($_ =~ /SSLLogLevel\s*[debug|info|notice|warn|error|crit|alert|emerg]/i){
        $out .= "SSLLogLevel debug\n";
      } else {
        $out .= $_;
      }
    }
    seek (F, 0, 0);
    print F $out;
    truncate (F, tell(F));
    close (F);
  }

  #####
  # Enable debugging for opmn.xml
  #####
  if( -e $opmnxml) {
    printf("Configuring debug directives in $opmnxml...\n");
    copy ($opmnxml, $opmnxml . "~ssodbg");
    open (F, "+< $opmnxml");
    $out='';
    my $inOC4Jsection=0;
    while (<F>) {
      if ($_ =~ /process-type id="OC4J_SECURITY"/i) {
        $inOC4Jsection=1;
      }
      if (($_ =~ /data id="java-options"/i) && ($inOC4Jsection == 1)) {
        $inOC4Jsection=0;
        $_ =~ s/"\/>/ -Dsun.security.krb5.debug=true -Djazn.debug.log.enable=true"\/>/i;
        $out .= $_;
      } else {
        $out .= $_;
      }
    }
    seek (F, 0, 0);
    print F $out;
    truncate (F, tell(F));
    close (F);
  }

  #####
  # Enable SSO plsql debugging
  #####
  printf("Running sqlplus to enable the debug_print procedure...\n");
  createSsoDbgOnFile();
  system("$oraclehome/bin/sqlplus -s system/$systempwd \@ssodbgon.sql");
  unlink "ssodbgon.sql";

  #####
  # Enable OID level 513 tracing (heavy debug + search filter)
  #####
  printf("Enabling OID tracing...\n");
  createLdifFile("513");
  my $cmdout=`$oraclehome/bin/ldapmodify -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl -f oiddbg.ldif`;
  unlink "oiddbg.ldif";

  #####
  # Restart processes with debug enabled
  #####
  startProcs("enabled");

  #####
  # Print date/time script completed
  #####
  printf("\nScript completed at %s.\n\n", today());
  printf("Debug mode is now enabled. Reproduce the reported issue and then ");
  printf("run\nthe command 'perl $0 -dbgoff' to disable debug mode.\n");
}

#####
# Disable debug mode for SSO, JAZN, and HTTP server
#####
sub dbgOff(){
  #####
  # Check to make sure debug is currently enabled
  #####
  if (! -e "$oraclehome/sso/conf/sso.dbg") {
    printf("\nCannot disable debugging. If debug mode has not already been ");
    printf("enabled\nthen run 'perl $0 -dbgon' to enable debug mode. If ");
    printf("this fails then you\nwill need to manually remove the ");
    printf("$oraclehome/sso/conf/sso.dbg\nfile and try again.\n");
    exit 1;
  }

  #####
  # Stop running processes
  #####
  stopProcs();

  # Disable debugging for policy.properties
  #####
  if (-e $policyproperties . "~ssodbg") {
    printf("\nDeconfiguring $policyproperties debug mode directives...\n");
    move ($policyproperties . "~ssodbg", $policyproperties);
  }

  #####
  # Disable debugging for httpd.conf
  #####
  if (-e $httpdconf . "~ssodbg") {
    printf("Deconfiguring $httpdconf debug mode directives...\n");
    move ($httpdconf . "~ssodbg", $httpdconf);
  }

  #####
  # Disable debugging for ssl.conf
  #####
  if (-e $sslconf . "~ssodbg") {
    printf("Deconfiguring $sslconf debug mode directives...\n");
    move ($sslconf . "~ssodbg", $sslconf);
  }

  #####
  # Disable debugging for opmn.xml
  #####
  if (-e $opmnxml . "~ssodbg") {
    printf("Deconfiguring $opmnxml debug mode directives...\n");
    move ($opmnxml . "~ssodbg", $opmnxml);
  }

  #####
  # Disable SSO plsql debugging
  #####
  printf("Running sqlplus to disable the debug_print procedure...\n");
  createSsoDbgOffFile();
  system("$oraclehome/bin/sqlplus -s system/$systempwd \@ssodbgoff.sql");
  unlink "ssodbgoff.sql";

  #####
  # Disable OID level 513 tracing (heavy debug + search filter)
  #####
  printf("Disabling OID tracing...\n");
  createLdifFile("0");
  my $cmdout=`$oraclehome/bin/ldapmodify -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl -f oiddbg.ldif`;
  unlink "oiddbg.ldif";

  #####
  # Remove the sso.dbg file indicating debug was enabled
  #####
  unlink "$oraclehome/sso/conf/sso.dbg";

  #####
  # Restart without debug enabled
  #####
  startProcs("disabled");
}

#####
# Collect SSO config files
#####
sub collect(){
  osInfo();
  iasSchemaVersions();
  dadStatus(); 
  ssoHtml();
  ssoOconf();
  getSessionTimeout();
  oidConfig();
  modOssoConf();
  getGITO();
  dcmctlStatus();
  opmnctlStatus();

  #####
  # Get the plsql debug file it it exists
  #####
  if (-e "wwsso_log.txt") {
    pushfile("wwsso_log.txt", "ssoarr");
  }

  #####
  # Build html files
  #####
  buildHtml();
  push(@filelist, "index.html");
  push(@filelist, "navigation.html");
  
  #####
  # Zip up all files into the output file
  #####
  printf("\nAdding configuration/log files to the output file...\n");
  foreach my $j (@filelist) {
    printf("\t%s\n", $j);
    system("zip -q -j $outputfile $j");
  }
  
  #####
  # Remove temporary files 
  #####
  printf("\nCleaning up temporary files...");
  unlink "sso.html";
  unlink "ssooconf.txt";
  unlink "ssogit.txt";
  unlink "dcmctl-status.txt";
  unlink "opmnctl-status.txt";
  unlink "osinfo.txt";
  unlink "oidconfig.txt";
  unlink "dadstatus.txt";
  unlink "wwsso_log.txt";
  unlink "schemaversions.txt";
  unlink "session_timeout.txt";
  unlink "index.html";
  unlink "navigation.html";
  my @files = <./*.clrtxt>;
  foreach my $unlinkfile (@files){
    unlink $unlinkfile;
  }
  
  #####
  # Add zip file comment to show date/time script was run
  #####
  my $now=today();
  system("echo Script completed at $now. | zip -q -z $outputfile");

  #####
  # Print date/time script completed
  #####
  printf("\n\nScript completed at $now.\n");
  printf("Please upload the file <$outputfile.zip> to metalink for Oracle support to review.\n");
}

sub today()
{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
  $mon=sprintf("%.2d", $mon+1);
  $mday=sprintf("%.2d", $mday);
  my $year4=$year + 1900;
  $hour=sprintf("%.2d", $hour);
  $min=sprintf("%.2d", $min);
  $sec=sprintf("%.2d", $sec);
  my $today="$hour:$min:$sec on $mon/$mday/$year4";
  return $today;
}

sub stopProcs()
{
  printf("\nStopping HTTP server...\n");
  my $cmdout=`$oraclehome/opmn/bin/opmnctl stopproc process-type=HTTP_Server`;
  printf("Stopping OC4J_SECURITY...\n");
  $cmdout=`$oraclehome/opmn/bin/opmnctl stopproc process-type=OC4J_SECURITY`;
}

sub startProcs()
{
  my $mode="@_";
  printf("\nReloading OPMN configuration data...\n");
  my $cmdout=`$oraclehome/opmn/bin/opmnctl reload`;
  printf("\nRestarting HTTP server with debug mode $mode...\n");
  my $cmdout=`$oraclehome/opmn/bin/opmnctl startproc process-type=HTTP_Server`;
  printf("Restarting OC4J_SECURITY with debug mode $mode...\n");
  $cmdout=`$oraclehome/opmn/bin/opmnctl startproc process-type=OC4J_SECURITY`;
}

sub getLastFile()
{
  my ($dir, $pattern)=@_;
  my @list=();
  opendir DIR, $dir;
  while (my $entry=readdir(DIR)) {
    if ($entry =~ /$pattern/i) {
      push(@list, $entry);
    }
  }
  closedir DIR;
  my @sorted=sort { -M "$dir/$a" <=> -M "$dir/$b" } @list;
  return $sorted[0];
}

sub createSsoDbgOnFile()
{
my $sqlfile=q!
set serveroutput on
set arraysize 1
set trims on
set linesize 240
set pagesize 0
set sqlprefix off
set verify off
set feedback off
set heading off
set timing off
set define on
set termout off
create or replace procedure orasso.debug_print (str varchar2) as
pragma autonomous_transaction;
begin
  insert into orasso.wwsso_log$ values (wwsso_log_pk_seq.nextval,
    substr(str, 1, 1000), sysdate, dbms_session.unique_session_id);
  commit;
end debug_print;
/
truncate table orasso.wwsso_log$;
exit;
!;
open SQLFILE, ">ssodbgon.sql";
print SQLFILE $sqlfile;
close SQLFILE;
}

sub createSsoDbgOffFile()
{
my $sqlfile=q!
set serveroutput on
set arraysize 1
set trims on
set linesize 1000
set pagesize 0
set sqlprefix off
set verify off
set feedback off
set heading off
set timing off
set define on
set termout off
column msg format a60 word_wrap
column session_id format a20
column log_date for a11 wrap

create or replace procedure orasso.debug_print (str varchar2) as
pragma autonomous_transaction;
begin
  null;
end debug_print;
/
spool wwsso_log.txt
select to_char(log_date,'mm/dd/yyyy hh24:mi:ss') log_date,
       substr(usession_id,1,15) session_id,
       msg from orasso.wwsso_log$ order by id;
spool off;
exit;
!;
open SQLFILE, ">ssodbgoff.sql";
print SQLFILE $sqlfile;
close SQLFILE;
}

sub createSsoOidSqlFile()
{
my $sqlfile=q!
clear buffer;
set serveroutput on
set arraysize 1
set trims on
set linesize 240
set pagesize 80
set sqlprefix off
set verify off
set feedback off
set heading on
set timing off
set define on
set termout off
spool ssooconf.txt
execute orasso.wwsso_oid_integration.show_ldap_config;
spool off;
exit;
!;
open SQLFILE, ">ssooid.sql";
print SQLFILE $sqlfile;
close SQLFILE;
}

sub createAppRegistryFile()
{
my $sqlfile=q!
set serveroutput on
set arraysize 1
set trims on
set linesize 240
set pagesize 80
set sqlprefix off
set verify off
set feedback off
set heading on
set timing off
set define on
set termout off
spool schemaversions.txt
SELECT comp_id, version, status FROM app_registry;
spool off;
exit;
!;
open SQLFILE, ">appregistry.sql";
print SQLFILE $sqlfile;
close SQLFILE;
}

sub createSessionTimeoutFile()
{
my $sqlfile=q!
set serveroutput on
set arraysize 1
set trims on
set linesize 240
set pagesize 80
set sqlprefix off
set verify on
set feedback off
set heading on
set timing off
set define on
set termout off
spool session_timeout.txt
SELECT SSO_COOKIE_LIFE_HRS from orasso.wwsso_ls_configuration_info_t;
spool off;
exit;
!;
open SQLFILE, ">sessiontimeout.sql";
print SQLFILE $sqlfile;
close SQLFILE;
}

sub parseSsooconfFile()
{
  my ($oidhost, $oidport, $oiduser, $oidpwd, $usessl, $ssl);
  open (SSOOCONF, "ssooconf.txt");
  foreach my $line (<SSOOCONF>) {
    my ($param, $value)=split(':',$line);
    $value =~ s/^\s*//;
    $value =~ s/\s+$//;
    if ($param eq "OID HOST") {
      $oidhost=$value;
    } elsif ($param eq "OID PORT") {
      $oidport=$value;
    } elsif ($param eq "SSO SERVER DN") {
      $oiduser=$value;
    } elsif ($param eq "OID USE SSL") {
      $usessl=$value;
    } elsif ($param eq "SSO SERVER PASSWORD") {
      $oidpwd=$value;
    }
  }
  $ssl="";
  if ($usessl eq "Y") {
    $ssl="-U 1";
  }
  close(SSOOCONF);
  return ($oidhost, $oidport, $oiduser, $oidpwd, $ssl);
}

sub createLdifFile()
{
  my $dbglevel="@_";
  open LDIFFILE, ">oiddbg.ldif";
  print LDIFFILE "dn:\n";
  print LDIFFILE "changetype: modify\n";
  print LDIFFILE "replace: orcldebugflag\n";
  print LDIFFILE "orcldebugflag: $dbglevel\n";
  close LDIFFILE;
}

sub createSsoHtmlSqlFile()
{
  my $sqlfile = q!
clear buffer;

set serveroutput on
set arraysize 1
set trims on
set linesize 240
set pagesize 0
set sqlprefix off
set verify off
set feedback off
set heading off
set timing off
set define on
set termout off

prompt V 1.02

spool sso.html 
select '<head><title>Infrastructure</title></head><body bgcolor="#fffccc">' from dual;
select '<body><div align=left><b><font face="Arial,Helvetica"><font color="#990000">' ||
       '<font size=-2>' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') || ' Ver 1.02 ' ||
       '</font></font></font></b></div></body>' from dual;

--start SSO Server VERSION
--select version from orasso.wwc_version$;
select '<h5><font face="VERDANA"><font color="#006600">SSO Server Version ' ||
       '<font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>SSO Server ' ||
       'Version </B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || version ||
       '</FONT></TD></TR>' from orasso.wwc_version$;
select '</TABLE>' FROM dual;
--COMMENT
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000"><font size=-2>' ||
       'This does not reflect any one-off patches that are installed' ||
       '</font></font></font></i></body>' from dual;
--end SSO Server VERSION


--start LOGIN SERVER ENABLER TABLE (WWSEC_ENABLER_CONFIG_INFO$)
select '<h5><font face="VERDANA"><font color="#006600">SSO Enabler info ' ||
       '<font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2> ORASSO ' ||
       'Schema (WWSEC_ENABLER_CONFIG_INFO$)</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || LSNR_TOKEN ||
       '</FONT></TD></TR>', '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       SITE_TOKEN || '</FONT></TD></TR>', '<TR><TD BGCOLOR=#FFFFF0>' ||
       '<FONT FACE="ARIAL" SIZE=2> ' || SITE_ID || '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || LS_LOGIN_URL ||
       '</FONT></TD></TR>', '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       URLCOOKIE_VERSION || '</FONT></TD></TR>', '<TR><TD BGCOLOR=#FFFFF0>' ||
       '<FONT FACE="ARIAL" SIZE=2> ' || ENCRYPTION_KEY || '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || ENCRYPTION_MASK_PRE ||
       '</FONT></TD></TR>', '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       ENCRYPTION_MASK_POST || '</FONT></TD></TR>', '<TR><TD BGCOLOR=#FFFFF0>' ||
       '<FONT FACE="ARIAL" SIZE=2> ' || URL_COOKIE_IP_CHECK || '</FONT></TD></TR>'
  from orasso.wwsec_enabler_config_info$;
select '</TABLE>' FROM dual;
--COMMENT
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000"><font size=-2>' ||
       'Check your httpd.conf file. Make sure that the servername, port used in ' ||
       'the file is reflected exactly in the WWSEC_ENABLER_CONFIG_INFO$ table. ' ||
       'Make sure you are using the servername with the domain. Also, check for ' ||
       'the slashes in the URL. If the settings are improper you may get error ' ||
       'WWC-41439. This table also stores settings for the Partner Application. ' ||
       '</font></font></font></i></body>' from dual;
--end LOGIN SERVER ENABLER TABLE 


--start LOGIN SERVER CONFIGURATION TABLE (WWSSO_PAPP_CONFIGURATION_INFO$)
-- select SITE_TOKEN, SITE_ID, SITE_NAME, SUCCESS_URL, FAILURE_URL, HOME_URL,
-- LOGOUT_URL, URLCOOKIE_PARAM, URLCOOKIE_VERSION, ENCRYPTION_KEY,
-- ENCRYPTION_MASK_PRE, ENCRYPTION_MASK_POST, START_DATE, END_DATE, ADMINISTRATOR_ID,
-- ADMINISTRATOR_INFO from ORASSO.wwsso_papp_configuration_info$;
select '<h5><font face="VERDANA"><font color="#006600">Login Server Config' ||
       'uration Table (WWSSO_PAPP_CONFIGURATION_INFO$) <font size=-2></font>' ||
       '</font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Partner ' ||
       'Application Info</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || SITE_TOKEN ||
       '</FONT></TD></TR>', '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       SITE_ID || '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || SITE_NAME ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || SUCCESS_URL ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || FAILURE_URL ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||HOME_URL||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || LOGOUT_URL ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || URLCOOKIE_PARAM ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || URLCOOKIE_VERSION ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || ENCRYPTION_KEY ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || ENCRYPTION_MASK_PRE ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || ENCRYPTION_MASK_POST ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || START_DATE ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || END_DATE ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || ADMINISTRATOR_ID ||
       '</FONT></TD></TR>',
       '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || ADMINISTRATOR_INFO ||
       '</FONT></TD></TR>' from orasso.wwsso_papp_configuration_info$;
select '</TABLE>' FROM dual;
-- COMMENT
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>WWSSO_PAPP_CONFIGURATION_INFO$ table stores information ' ||
       'regarding Partner Applications. </font></font></font></i></body>' from dual;
--end LOGIN SERVER CONFIGURATION TABLE 


--start CUSTOM LOGIN CONFIGURATION TABLE (WWSSO_LS_CONFIGURATION_INFO$)
-- select login_url, listener_host_name, port from ORASSO.wwsso_ls_configuration_info$;
select '<h5><font face="VERDANA"><font color="#006600">Custom Login Configuration ' ||
       'Table (WWSSO_LS_CONFIGURATION_INFO$) <font size=-2></font></font></font></h5>'
    FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Login URL' ||
       '</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Listener ' ||
       'Host Name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>Port</B>' ||
       '</FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || login_url ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       listener_host_name || '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || port|| '</FONT></TD></TR>'
     from orasso.wwsso_ls_configuration_info$;
select '</TABLE>' FROM dual;
-- COMMENT
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>WWSSO_LS_CONFIGURATION_INFO$ stores custom Login ' ||
       'information. If you are not using Custom Login you will see ' ||
       'UNUSED UNUSED UNUSED. You may see WWC-41963 error for improper settings.' ||
       '</font></font></font></i></body>' from dual;
--end CUSTOM LOGIN CONFIGURATION TABLE


--start COOKIE INFO
-- select cookie_name from ORASSO.WWCTX_COOKIE_INFO$;
select '<h5><font face="VERDANA"><font color="#006600">SSO COOKIE INFO ' ||
       '<font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'ORASSO Cookie Name</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2>' || cookie_name ||
       '</FONT></TD></TR>' from orasso.WWCTX_COOKIE_INFO$;
select '</TABLE>' FROM dual;
--end COOKIE INFO


--start INFRASTRUCTURE DATABASE VERSION
-- select banner from v$version;
select '<h5><font face="VERDANA"><font color="#006600">Infrastructure Database ' ||
       'Version <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || banner ||
       '</FONT></TD></TR>' from v$version;
select '</TABLE>' FROM dual;
-- COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>Check version / edition - Standard or Production' ||
       '</font></font></font></i><br><i><font face="Arial,Helvetica">' ||
       '<font size=-2><font color="#FF0000">Check the </font>' ||
       '<font color="#993300"><a href="http://metalink.oracle.com/metalink/' ||
       'plsql/certify.welcome" target="new">Certification Matrix</a></font>' ||
       '<font color="#FF0000"> for details</font></font></font></i></body>' from dual;
--end INFRASTRUCTURE DATABASE VERSION


--start PL/SQL TOOLKIT VERSION
-- select owa_util.get_version from dual;
select '<h5><font face="VERDANA"><font color="#006600">PL/SQL Toolkit ' ||
       'Version <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || owa_util.get_version  ||
       '</FONT></TD></TR>' from dual;
select '</TABLE>' FROM dual;
-- COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>Check the toolkit version. If less than 9.0.2.0.1 then ' ||
       'upgrade (discuss with Oracle Support before upgrading)</font></font>' ||
       '</font></i></body>' from dual;
--end PL/SQL TOOLKIT VERSION


--start DUPLICATE OWA PACKAGES 
-- SELECT OWNER, OBJECT_TYPE FROM DBA_OBJECTS WHERE OBJECT_NAME = 'OWA';
select '<h5><font face="VERDANA"><font color="#006600">Duplicate OWA ' ||
       'packages <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Owner</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Object Type</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || owner ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       object_type || '</FONT></TD></TR>' FROM DBA_OBJECTS    WHERE OBJECT_NAME = 'OWA';
select '</TABLE>' FROM dual;
-- COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>Make sure you do not have duplicate copies of OWA ' ||
       'packages. You should see the output as below:</font></font></font>' ||
       '</i><br><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>SYS...........PACKAGE</font></font></font></i>' ||
       '<br><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>SYS...........PACKAGE BODY</font></font></font></i>' ||
       '<br><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>PUBLIC.....SYNONYM</font></font></font></i></body>'
   from dual;
--end DUPLICATE OWA PACKAGES 


--start USER ENVIRONMENT
-- select USERENV('TERMINAL'), USERENV('LANGUAGE') FROM DUAL;
select '<h5><font face="VERDANA"><font color="#006600">' ||
       'User Environment<font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Terminal</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Language</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       USERENV('TERMINAL') || '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       USERENV('LANGUAGE')|| '</FONT></TD></TR>' from dual;
select '</TABLE>' FROM dual;
-- COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>If this script is run from the middle-tier, you ' ||
       'should see the Terminal Name and the Language it is set to. ' ||
       'Compare these settings with the <b>Language, Database Character' ||
       'set Support</b> and the <b>init.ora</b> settings below</font>' ||
       '</font></font></i></body>' from dual;
--end USER ENVIRONMENT


--start DATABASE CHARACTERSET SUPPORT
-- select parameter, value from nls_database_parameters;
select '<h5><font face="VERDANA"><font color="#006600">Database ' ||
       'Characterset Support <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Parameter</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Characterset Value</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2>' || parameter ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2>' ||
       value || '</FONT></TD></TR>' from nls_database_parameters; 
select '</TABLE>' FROM dual;
--end --start DATABASE CHARACTERSET SUPPORT


--start INIT<SID>.ORA PARAMETERS FROM V$PARAMETER TABLE
-- select name, value from V$parameter where lower(name) in
-- ('java_pool_size', 'large_pool_size', 'shared_pool_size',
-- '_system_trig_enabled', 'db_name', 'db_domain', 'db_block_size',
-- 'db_cache_size', 'instance_name', 'service_names', 'open_cursors',
-- 'cursor_sharing', 'max_enabled_roles', 'mts_dispatchers', 'sessions',
-- 'processes', 'compatible', 'o7_dictionary_accessibility', 'nls_language',
-- 'event', 'optimizer_mode', 'job_queue_processes') order by name;
select '<h5><font face="VERDANA"><font color="#006600">init.ora ' ||
       'Paramaters <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Value</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || name ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       value || '</FONT></TD></TR>'
   from V$parameter where lower(name) in
    ('java_pool_size', 'large_pool_size', 'shared_pool_size',
     '_system_trig_enabled', 'db_name', 'db_domain', 'db_block_size',
     'db_cache_size', 'instance_name', 'service_names', 'open_cursors',
     'cursor_sharing', 'max_enabled_roles', 'mts_dispatchers', 'sessions',
     'processes', 'compatible', 'o7_dictionary_accessibility',
     'nls_language', 'event', 'optimizer_mode', 'job_queue_processes')
   order by name;
select '</TABLE>' FROM dual;
--end INIT<SID>.ORA PARAMETERS


--start SGA INFORMATION
-- select pool, name, bytes from v$sgastat where name in
-- ('fixed_sga', 'free memory', 'sessions', 'processes', 'memory in use',
-- 'db_block_buffers');
select '<h5><font face="VERDANA"><font color="#006600">SGA Information ' ||
       '<font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Pool</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Bytes</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || pool ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       name || '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || bytes ||
       '</FONT></TD></TR>'
   from v$sgastat where name in
    ('fixed_sga', 'free memory', 'sessions', 'processes', 'memory in use',
     'db_block_buffers');
select '</TABLE>' FROM dual;
--end SGA INFORMATION


--start LIST OF INVALID OBJECTS IN THE DATABASE
-- select OWNER, object_name, object_type, status
--  from all_objects where status like '%INVALID%';
select '<h5><font face="VERDANA"><font color="#006600">' ||
       'List of Invalid Objects <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Owner</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Object Name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Object type</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Status</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || OWNER ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       object_name || '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || object_type ||
       '</FONT></TD>','<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       status || '</FONT></TD></TR>'
   from all_objects where status like '%INVALID%';
select '</TABLE>' FROM dual;
--end LIST OF INVALID OBJECTS IN THE DATABASE


--start TOTAL INVALID OBJECTS
-- select count(1) from all_objects where status like '%INVALID%';
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Total Invalid Objects</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || count(1) ||
       '</FONT></TD></TR>' from all_objects where status like '%INVALID%';
select '</TABLE>' FROM dual;
-- COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>There should be no INVALID objects in the database ' ||
       'pertaining to the owners within Portal and SYS owner. If there ' ||
       'are any, recompile. Use the <b>utlrp.sql</b>script under the ' ||
       'database home to recompile.</font></font></font></i></body>' from dual;
--end TOTAL INVALID OBJECTS


--start ORASSO user TABLESPACE INFO
-- select username, created, default_tablespace, temporary_tablespace
--  from dba_users where username in 
--   upper('orasso'), upper('orasso'||'_PUBLIC'),  upper('orasso'||'_PS'),
--   upper('orasso'||'_DS'), upper('orasso'||'_PA')) OR username like 'LBACSYS';
select '<h5><font face="VERDANA"><font color="#006600">Users With ' ||
       'Tablespace Info <font size=-2></font></font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Username</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Created</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Default Tablespace</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Temporary Tablespace</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || username ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       created || '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || default_tablespace ||
       '</FONT></TD>', '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       temporary_tablespace || '</FONT></TD></TR>'
   from dba_users where username in 
    (upper('orasso'), upper('orasso'||'_PUBLIC'), upper('orasso'||'_PS'),
     upper('orasso'||'_DS'), upper('orasso'||'_PA')) OR username like 'LBACSYS';
select '</TABLE>' FROM dual;
--end ORASSO user TABLESPACE INFO


--start FREE SPACE IN TABLESPACE FROM DBA_FREE_SPACE IN MEGABYTES
-- select tablespace_name, sum(bytes)/1048576 from dba_free_space
--  where tablespace_name in
--   (select default_tablespace from dba_users where username = 'PORTAL')
--  group by tablespace_name order by tablespace_name;
select '<h5><font face="VERDANA"><font color="#006600">Free Space ' ||
       'in Tablespace for ORASSO Database user <font size=-2></font>' ||
       '</font></font></h5>' FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Default Tablespace</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Free Tablespace(MB)</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       tablespace_name || '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       sum(bytes)/1048576 || '</FONT></TD></TR>'
   from dba_free_space
   where tablespace_name in
    (select default_tablespace from dba_users where username = upper('orasso'))
   group by tablespace_name order by tablespace_name;
select '</TABLE>' FROM dual;
-- COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>Make sure you have enough free space in the ' ||
       'tablespace that Portal uses. If it is low, increase the tablespace. ' ||
       'Low space would affect the functioning of Portal.</font></font>' ||
       '</font></i></body>' from dual;
--end FREE SPACE IN TABLESPACE FROM DBA_FREE_SPACE IN MEGABYTES


--start EXTENTS OF TABLESPACE FROM DBA_TABLESPACES
select '<h5><font face="VERDANA"><font color="#006600">Extents of ' ||
       'Tablespaces For ORASSO  <font size=-2></font></font></font></h5>'
   FROM dual;
select '<TABLE BORDER  CELLPADDING=2>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Tablespace Name</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Initial Extent</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Next Extent</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Pct Increase</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Allocation Type</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Segment Space Management</B></FONT></TH>' FROM dual;
select '<TH BGCOLOR=#006600><B><FONT FACE="ARIAL" COLOR="#FFFFFF" SIZE=2>' ||
       'Extent Management</B></FONT></TH>' FROM dual;
select '<TR><TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       tablespace_name || '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || initial_extent ||
       '</FONT></TD>','<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       next_extent || '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || pct_increase ||
       '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || allocation_type ||
       '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' ||
       SEGMENT_SPACE_MANAGEMENT || '</FONT></TD>',
       '<TD BGCOLOR=#FFFFF0><FONT FACE="ARIAL" SIZE=2> ' || extent_management ||
       '</FONT></TD></TR>' from dba_tablespaces
   where tablespace_name in
    (select default_tablespace from dba_users where username = upper('orasso'));
select '</TABLE>' FROM dual;
-- COMMENTS
select '<body><i><font face="Arial,Helvetica"><font color="#FF0000">' ||
       '<font size=-2>Check for the extents, extent Management and ' ||
       'Segment Space Management for tablespace. If Segment Space Management ' ||
       'is set to manual means the tablespace is not auto extentable.</font>' ||
       '</font></font></i></body>' from dual;
--end EXTENTS OF TABLESPACE FROM DBA_TABLESPACES

spool off
exit
!;
open SQLFILE, ">sso.sql";
print SQLFILE $sqlfile;
close SQLFILE;
}

sub createSsoGitSqlFile()
{
my $sqlfile = q!
clear buffer;
set serveroutput on
set arraysize 1
set trims on
set linesize 240
set pagesize 0
set sqlprefix off
set verify off
set feedback off
set heading off
set timing off
set define on
set termout off
spool ssogit.txt
declare
   l_cookie_name      varchar2(1000);
   l_cookie_domain    varchar2(1000);
   l_encryption_key   varchar2(1000);
   l_git_duration     number;
   l_git_enabled      number;
begin
    dbms_output.put_line('=============================================');
    dbms_output.put_line(' SSO Server Inactivity Timeout Configuration');
    dbms_output.put_line('=============================================');
    orasso.wwsso_ls_private.get_timeout_params
       (
         p_cookie_name  => l_cookie_name
       , p_domain       => l_cookie_domain
       , p_duration     => l_git_duration
       , p_enable       => l_git_enabled
       , p_enc_key      => l_encryption_key
       ); 
    if(l_git_enabled > 0) then
       dbms_output.put_line('Timeout          : ENABLED');
    else
       dbms_output.put_line('Timeout          : DISABLED');
    end if;
    dbms_output.put_line('Cookie name      : ' || l_cookie_name);
    DBMS_OUTPut.put_line('Cookie domain    : ' || l_cookie_domain);
    dbms_output.put_line('Inactivity period: ' || l_git_duration || ' minutes');
    dbms_output.put_line('Encryption key   : ' || l_encryption_key);
    if(l_cookie_domain is null) then
       dbms_output.put_line('Note: timeout cookie domain will be defaulted');
       dbms_output.put_line('to the SSO Server hostname'); 
    end if;
    dbms_output.put_line('-------------------------------------------');
end;
/
spool off;
exit;
!;
open SQLFILE, ">ssogit.sql";
print SQLFILE $sqlfile;
close SQLFILE;
}

sub parseTargetsXml()
{
  open (G, "+< $targetsxml");
  my $inSSOsection=0;
  my ($param1, $param2, $httpHost, $httpPort, $httpProtocol);
  while (<G>) {
    if ($_ =~ /oracle_sso_server/i) {
      $inSSOsection=1;
      next;
    }
    if (($_ =~ /HTTPMachine/i) && ($inSSOsection == 1)) {
      ($param1, $param2, $httpHost) = split('=', $_);
      $httpHost =~ s/["\/>]//g;
      chomp $httpHost;
    } elsif (($_ =~ /HTTPPort/i) && ($inSSOsection == 1)) {
      ($param1, $param2, $httpPort) = split('=', $_);
      $httpPort =~ s/["\/>]//g;
      chomp $httpPort;
    } elsif (($_ =~ /HTTPProtocol/i) && ($inSSOsection == 1)) {
      ($param1, $param2, $httpProtocol) = split('=', $_);
      $httpProtocol =~ s/["\/>]//g;
      chomp $httpProtocol;
    } elsif ($_ =~ /Target TYPE/i) {
      $inSSOsection=0;
    }
  }
  close (G);
  return ($httpHost, $httpPort, $httpProtocol);
}

sub osInfo()
{
  #####
  # Gather OS info
  #####
  printf("\nCollecting OS info...\n");
  system("echo ORACLE_HOME=$oraclehome > osinfo.txt");
  open (F, "< $oraclehome/config/ias.properties");
  my ($paramName, $paramValue);
  while (<F>) {
    if ($_ =~ /IASname/i){
      $_ =~ s/^\s+//;
      ($paramName, $paramValue)=split(/=/,$_);
      last;
    }
  }
  close (F);
  system("echo 'IAS Instance Name=$paramValue' >> osinfo.txt");
  if ($^O =~ /win/i) {
    system('ver >> osinfo.txt');
  } else {
    system('uname -a >> osinfo.txt');
  }
  my $host = hostname() || 'localhost';
  my ($name, $aliases, $addrtype, $length, @addrs) = gethostbyname($host);
  system("echo hostname=$name >> osinfo.txt");
  system("echo aliases=$aliases >> osinfo.txt");
  my $num_addrs = @addrs;
  for (my $i = 0; $i < $num_addrs; $i++) {
    my $ipaddr = inet_ntoa($addrs[$i]);
    system("echo IP addr: $ipaddr >> osinfo.txt");
    my $me = gethostbyaddr(inet_aton($ipaddr), AF_INET);
    system("echo Reverse lookup of $ipaddr: $me >> osinfo.txt");
  }
  pushfile("osinfo.txt", "osarr");
}

sub dadStatus()
{
  #####
  # Check status of the /pls/orasso DAD
  #####
  if ((-e $dadsconf) && ($LWPfound == 1)) {
    open (F, "< $dadsconf");
    while (<F>) {
      if ($_ =~ /Location\s\/pls\/orasso/i) {
        printf("Checking status of the /pls/orasso DAD...\n");
        my ($httpHost, $httpPort, $httpProtocol)=parseTargetsXml();
        my $url=$httpProtocol . "://" . $httpHost . ":" . $httpPort;
        $url=$url . "/pls/orasso/htp.p?cbuf=test";
        open (G, ">dadstatus.txt");
        my $ua = LWP::UserAgent->new();
        my $req = HTTP::Request->new(GET => $url);
        my $response = $ua->request($req);
        printf G "Ping URL: $url\n";
        printf G "HTTP response: %s\n", $response->status_line;
        if ($response->is_error()) {
          printf G "/pls/orasso DAD is DOWN\n";
        } else {
          printf G "/pls/orasso DAD is UP\n";
        }
        close (G);
        pushfile("dadstatus.txt", "httparr");
      }
    }
    close (F);
  } elsif ($LWPfound == 0) {
    system("echo Perl LWP module not found...cannot check /pls/orasso DAD Status > dadstatus.txt");
    pushfile("dadstatus.txt", "httparr");
  }
}

sub ssoHtml()
{
  #####
  # Run sqlplus and execute the sso.sql script from note 244112.1
  #####
  printf("Running sqlplus to generate the sso.html file...\n");
  createSsoHtmlSqlFile();
  system("$oraclehome/bin/sqlplus -s system/$systempwd \@sso.sql");
  pushfile("sso.html", "ssoarr");
  unlink "sso.sql";
}

sub ssoOconf()
{
  #####
  # Run sqlplus and capture ssooconf.sql output
  #####
  printf("Checking SSO->OID connection settings...\n");
  createSsoOidSqlFile();
  system("$oraclehome/bin/sqlplus -s system/$systempwd \@ssooid.sql");
  my ($oidhost, $oidport, $oiduser, $oidpwd, $ssl)=parseSsooconfFile();
  if ($^O =~ /win/i){
    system("echo. >> ssooconf.txt");
  } else {
    system("echo \"\" >> ssooconf.txt")
  }
  system("echo $oraclehome/bin/ldapbind -h $oidhost -p $oidport -D $oiduser -w $oidpwd $ssl >> ssooconf.txt");
  system("$oraclehome/bin/ldapbind -h $oidhost -p $oidport -D $oiduser -w $oidpwd $ssl >> ssooconf.txt 2>&1");
  pushfile("ssooconf.txt", "ssoarr");
  unlink "ssooid.sql";
}

sub oidConfig()
{
  #####
  # Run ldapsearch to collect OID search base defintions
  #####
  printf("Checking OID configuration...\n");
  open(W, ">oidconfig.txt");

  printf W "OID Directory version\n=====================\n";
  my $cmd="$oraclehome/bin/ldapsearch -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl -b \"\" -s base objectclass=* orcldirectoryversion";
  my $cmdout = `$cmd`;
  printf W "%s\n\n", substr($cmdout, 1);

  printf W "OID attribute configuration\n===========================\n";
  $cmd = "$oraclehome/bin/ldapsearch -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl -b \"cn=Common,cn=Products,cn=OracleContext\" -s base objectclass=* orcldefaultsubscriber";
  $cmdout = `$cmd`;
  my ($dn, $subscriber) = split("\n", $cmdout);
  my ($keyword, $defaultrealm) = split("=", $subscriber, 2);
  $cmd="$oraclehome/bin/ldapsearch -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl -b \"cn=Common,cn=Products,cn=OracleContext," . $defaultrealm . "\" -s base objectclass=*";
  $cmdout = `$cmd`;
  printf W "$cmdout\n\n";

  printf W "OID plugin configuration\n========================\n";
  $cmd="$oraclehome/bin/ldapsearch -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl -b \"cn=plugin,cn=subconfigsubentry\" -s sub objectclass=*";
  $cmdout = `$cmd`;
  printf W "$cmdout\n\n";
  
  printf W "OID DAS URL base setting\n========================\n";
  $cmd="$oraclehome/bin/ldapsearch -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl -b \"cn=OperationURLs,cn=DAS,cn=Products,cn=OracleContext\" -s base objectclass=* orcldasurlbase";
  $cmdout = `$cmd`;
  printf W "$cmdout\n\n";

  printf W "OID metadata repository connect string\n======================================\n";
  open (F, "< $oraclehome/config/ias.properties");
  my ($paramName, $tnsstring);
  while (<F>) {
    if ($_ =~ /InfrastructureDBCommonName/i){
      $_ =~ s/^\s+//;
      ($paramName, $tnsstring)=split(/=/,$_);
      last;
    }
  }
  close (F);
  my ($alias,$junk) = split('\.', $tnsstring, 2);
  $cmd="$oraclehome/bin/ldapsearch -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl -b \"cn=" . $alias . ",cn=OracleContext\" -s base objectclass=* orclnetdescstring";
  $cmdout = `$cmd`;
  printf W "$cmd\n";
  printf W "$cmdout\n\n";
  
  printf W "OID database password\n=====================\n";
  $cmd="$oraclehome/bin/ldapsearch -h $oidhost -p $oidport -D cn=orcladmin -w $oidpasswd $ssl -b \"cn=IAS Infrastructure Databases,cn=IAS,cn=Products,cn=OracleContext\" -s sub orclResourceName=orasso orclpasswordattribute";
  my @cmdout = `$cmd`;
  printf W "@cmdout\n";
  foreach my $i (@cmdout) {
    if ($i =~ /orclpasswordattribute/i) {
      my ($variable, $orassopwd) = split('=', $i);
      chomp ($orassopwd);
      if ($systempwd =~ "\@") {
        my ($pwd,$alias)=split('\@', $systempwd);
        $orassopwd .= '@' . $alias;
      }
      my $status=verifyDatabasePassword("orasso", $orassopwd);
      if ($status) {
        printf W "Unable to connect to database as orasso/$orassopwd\n\n";
      } else {
        printf W "Successfully connected to database as orasso/$orassopwd\n\n";
      }
    }
  }
  
  close (W);
  pushfile("oidconfig.txt", "oidarr");
}

sub modOssoConf()
{
  #####
  # Parse the httpd.conf, ssl.conf, & mod_osso.conf file to get the OssoConfigFile parameter
  # Decrypt the osso.conf file(s) into cleartext
  #####
  foreach my $j ($httpdconf, $sslconf, $modossoconf){
    my $ossoconf='';
    my $paramName='';
    open (F, "< $j");
    while (<F>) {
      if ($_ =~ /OssoConfigFile/i){
        $_ =~ s/^\s+//;
        ($paramName, $ossoconf)=split(/\s+/,$_);
        my $base=basename($ossoconf);
        printf("Decrypting the $base file...\n");
        my $ossoclrtxt="./$base.clrtxt";
        system("$oraclehome/Apache/Apache/bin/ssomigrate $ossoconf $ossoconf clrtxt $ossoclrtxt");
        pushfile("$ossoclrtxt", "httparr");
      }
    }
    close (F);
  }
}

sub getGITO()
{
  #####
  # Capture GIT info
  #####
  printf("Checking current GIT settings...\n");
  createSsoGitSqlFile();
  system("$oraclehome/bin/sqlplus -s system/$systempwd \@ssogit.sql");
  pushfile("ssogit.txt", "ssoarr");
  unlink "ssogit.sql";
}

sub iasSchemaVersions()
{
  #####
  # Get schema versions from metadata repository
  #####
  printf("Collecting schema versions from metadata repository...\n");
  createAppRegistryFile();
  system("$oraclehome/bin/sqlplus -s system/$systempwd \@appregistry.sql");
  pushfile("schemaversions.txt", "iasarr");
  unlink "appregistry.sql";
}

sub getSessionTimeout()
{
  #####
  # Get the session timeout value from the wwsso_ls_configuration_info_t table
  #####
  printf("Checking session timeout setting...\n");
  createSessionTimeoutFile();
  system("$oraclehome/bin/sqlplus -s system/$systempwd \@sessiontimeout.sql");
  pushfile("session_timeout.txt", "ssoarr");
  unlink "sessiontimeout.sql";
}

sub dcmctlStatus()
{
  #####
  # Run dcmctl getstate -v
  #####
  printf("Running 'dcmctl getstate -v'...\n");
  system("$oraclehome/dcm/bin/dcmctl getstate -v > dcmctl-status.txt 2>&1");
  pushfile("dcmctl-status.txt", "iasarr");
}

sub opmnctlStatus()
{
  #####
  # Run opmnctl status
  #####
  printf("Running 'opmnctl status -l'...\n");
  system("$oraclehome/opmn/bin/opmnctl status -l > opmnctl-status.txt 2>&1");
  pushfile("opmnctl-status.txt", "iasarr");
}

sub verifyDatabasePassword()
{
  my ($user, $pwd)=@_;
  my $credentials="connect $user/" . $pwd;
  my $cmd="$oraclehome/bin/sqlplus -s /nolog";
  my $output;
  use FileHandle;
  use IPC::Open2;
  use Symbol qw(gensym);
  my $temp=rand();
  open(RDR,'>'.$temp);
  my $WTR=gensym();
  my $pid=open2(">&RDR", $WTR, "$cmd");
  print $WTR "$credentials\n";
  print $WTR "exit;\n";
  close $WTR;
  waitpid $pid,0;
  close RDR;
  open(RDR,$temp);
  while(<RDR>) {
     $output .= $_;
  }
  close RDR;
  unlink $temp;
  $_=$output;
  my $mat='ERROR:';
  my $ind= m/$mat/ ;
  if($ind != 0){
     return 1 ;
  }
  return 0 ;
}

sub pushfile()
{
  my ($fullname, $category)=@_;
  my $filename=basename($fullname);
  if ((-r $fullname) && (-f $fullname))  {
    push(@filelist, $fullname);
    if ($category eq "httparr") {
      push(@httparr, $filename);
    } elsif ($category eq "ssoarr") {
        push(@ssoarr, $filename);
    } elsif ($category eq "wnaarr") {
        push(@wnaarr, $filename);
    } elsif ($category eq "iasarr") {
        push(@iasarr, $filename);  
    } elsif ($category eq "osarr") {
        push(@osarr, $filename);  
    } elsif ($category eq "oidarr") {
        push(@oidarr, $filename);
    } elsif ($category eq "webcachearr") {
	    push(@webcachearr, $filename);
	}
  }
}

sub buildHtml()
{
  #####
  # Build index.html
  #####
  open (F, "> index.html");
  print F "<html><frameset cols=\"25%,*\">\n";
  print F "<frame src=navigation.html>\n";
  print F "<frame src=sso.html name=details>\n";
  print F "</frameset></html>\n";
  close (F);
  
  #####
  # Build navigation.html
  #####
  open (F, "> navigation.html");
  print F "<body bgcolor=#fffccc>\n";
  print F "<b>OS Info</b>\n<ul>\n";
  foreach my $k (@osarr) {
    print F "<li><a target=details href=$k>$k</a><br>\n";
  }
  print F "</ul><b>HTTP Files</b>\n<ul>\n";  
  foreach my $k (@httparr) {
    print F "<li><a target=details href=$k>$k</a><br>\n";
  }
  print F "</ul><b>SSO Files</b>\n<ul>\n";  
  foreach my $k (@ssoarr) {
    print F "<li><a target=details href=$k>$k</a><br>\n";
  }
  print F "</ul><b>WNA Files</b>\n<ul>\n";  
  foreach my $k (@wnaarr) {
    print F "<li><a target=details href=$k>$k</a><br>\n";
  }
  print F "</ul><b>iAS Files</b>\n<ul>\n";  
  foreach my $k (@iasarr) {
    print F "<li><a target=details href=$k>$k</a><br>\n";
  }
  print F "</ul><b>OID Files</b>\n<ul>\n";  
  foreach my $k (@oidarr) {
    print F "<li><a target=details href=$k>$k</a><br>\n";
  }
  print F "</ul><b>Webcache Files</b>\n<ul>\n";  
  foreach my $k (@webcachearr) {
    print F "<li><a target=details href=$k>$k</a><br>\n";
  }  
  print F "</ul><body>";
  close (F);
}
