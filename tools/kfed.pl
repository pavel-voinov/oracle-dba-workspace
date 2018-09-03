#!/usr/bin/perl

# kfed.pl
# Input kfed_DH.out or kfed_BK.out
# Usage : kfed.pl kfed_DH.out | sort -t ' ' -k 2.3

# 2012/05/07 kyle Heo Added Pattern matching for all components
# 2012/05/06 kyle Heo Added Pattern matching for crestmphi/crestmplo & apply pattern capturing for asmlabel
# 2011/10/11 kyle Heo Added Voting Files information
# 2011/08/07 kyle Heo Added "N/A" for no ASMLabel
# 2011/07/24 kyle Heo Added Disk Size & Creation time
# 2011/06/03 kyle Heo Added Add ASMlabel
# 2011/03/26 kyle Heo dos2unix filename - To fix \r\n issue

use warnings;
use strict;

#Device Name String
#my $deviceM = '^\.';
my $deviceM = '^/dev/';
#my $deviceM = '^/u02/';
#my $deviceM = '^ora_';
#my $deviceM = "^asm";
#my $deviceM = "^\/fra";

my $device ="NOASMDEVICE" ;
my $dskname ;
my $dsknum ;
my $grpname ;
my $fgname ;
my $hdrsts;
my $grptyp;
my $f1b1locn;
my $asmlabel;
my $dsksize;
my $vf=0;
my ($crestmphi, $crestmplo, $c_secs, $c_mins, $c_hour, $c_days, $c_mnth, $c_year ) ;
my ($secs, $mins, $hour, $days, $mnth, $year );

my %tmp;
my @fields ;
my $num_args;

$num_args = $#ARGV + 1;
die "Usage: kfed.pl kfed_DH.out | sort -t ' ' -k 2.3 | more " if ($num_args != 1);

#Print Header
printf "%-30s %-15s %-8s %-15s %-15s %-15s %-10s %-8s %-2s %-14s\n" ,
"1.Device" ,"2.GroupName", "3.DN#(Size)", "4.DiskName", "5.ASMLabel", "6.FailGroup" ,
"7.H_Staus" , "8.Rdancy", "F1(V)" , "Creation Time" ;


while (<>) {

# To remove \r\n from dos format
s/^\s+//; s/\s+$// ;

if ( $_ =~ /$deviceM/ ) {
if ( $device =~ /NOASMDEVICE/ ) {
$device = $_ ;
next;
}
elsif ( $device && $grpname )
{
printf "%-30s %-15s %04d(%s) %-15s %-15s %-15s %-10s %-8s %-2s(%3s) %s%s \n" ,
$device, $grpname, $dsknum, $dsksize, $dskname, $asmlabel, $fgname ,
$hdrsts , $grptyp, $f1b1locn,$vf, $crestmphi, $crestmplo ;

$device = $_ ;
$grpname="";
next ;
} else {
printf "%-30s %-15s \n" , $device , "ZZZ - NO ASM DEVICE" ;

$device = $_ ;
next;
}

}

if ( $_ =~ /dskname:\s*(\w+)/ ) { $dskname = $1; }
elsif ( $_ =~ /dsknum:\s*(\w+)/ ) { $dsknum = $1; }
elsif ( $_ =~ /grpname:\s*(\w+)/ ) { $grpname = $1; }
elsif ( $_ =~ /fgname:\s*(\w+)/ ) { $fgname = $1; }
elsif ( $_ =~ /f1b1locn:\s*(\w+)/) { $f1b1locn = $1; }
elsif ( $_ =~ /dsksize:\s*(\w+)/ ) { $dsksize = $1; }
elsif ( $_ =~ /vfstart:\s*(\w+)/ ) { $vf = $1; }
elsif ( $_ =~ /hdrsts:(.*KFDHDR_)(\w+$)/ ) { $hdrsts = $2; }
elsif ( $_ =~ /grptyp:(.*KFDGTP_)(\w+$)/ ) { $grptyp = $2; }
elsif ( $_ =~ /provstr:\s*(\w+)/ ) {
$asmlabel = $1;
if ( $asmlabel eq "ORCLDISK" ) { $asmlabel = "N/A" }
else { $asmlabel =~ s/ORCLDISK//; };

}
elsif ( $_ =~ /crestmp\.hi/ ) {
@fields = split /:/, $_ ;
%tmp = $fields[2] =~ /(\w+)=(\w+)/g;

$c_year = sprintf( "%d", hex( $tmp{YEAR} ) );
$c_mnth = sprintf( "%02d", hex( $tmp{MNTH} ) );
$c_days = sprintf( "%02d", hex( $tmp{DAYS} ) );
$c_hour = sprintf( "%02d", hex( $tmp{HOUR} ) );

$crestmphi = sprintf ( "%s/%s/%s %s", $c_year, $c_mnth, $c_days, $c_hour );
}

elsif ( $_ =~ /crestmp\.lo/ ) {
@fields = split /:/, $_ ;
%tmp = $fields[2] =~ /(\w+)=(\w+)/g;

$c_mins = sprintf( "%02d", hex($tmp{MINS}) );
$c_secs = sprintf( "%02d", hex($tmp{SECS}) );

$crestmplo = sprintf ( ":%s:%s", $c_mins, $c_secs);
}
}

if ( $device && $grpname )
{
printf "%-30s %-15s %04d(%s) %-15s %-15s %-15s %-10s %-8s %-2s(%3s) %s%s \n" ,
$device, $grpname, $dsknum, $dsksize, $dskname, $asmlabel, $fgname ,
$hdrsts , $grptyp, $f1b1locn,$vf, $crestmphi, $crestmplo ;
}

