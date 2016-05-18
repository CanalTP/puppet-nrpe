#!/usr/bin/perl -w
#
# File managed by puppet, don't edit directly
#
# check_syslog.pl - Nagios check plugin for testing a local Syslog-ng server through UDP 
#
# -- Written 2009/08/18 Mihaly Szummer <mihalysz@email.com>
#
# Source: http://exchange.nagios.org/directory/Plugins/Log-Files/check_syslog/details
# gdelacour 20150408: add a sleep(1) to let syslog write on disk

use strict;
use Sys::Syslog qw(:DEFAULT setlogsock);

use lib "/usr/lib/nagios/plugins";
use utils qw($TIMEOUT %ERRORS &print_revision &support &usage);

use Getopt::Long;
use vars qw( $opt_v $opt_h $opt_l $opt_f );

use vars qw( $remotehost $filename );

sub print_help();
sub print_usage();

my $progname='check_syslog.pl';
my $revision='0.1';

Getopt::Long::Configure ('bundling');
GetOptions(
	"v"	=> \$opt_v, "version"	=> \$opt_v,
	"h"	=> \$opt_h, "help"	=> \$opt_h,
	"l=s"	=> \$opt_l, "loghost=s"	=> \$opt_l,
	"f=s"	=> \$opt_f, "logfile=s"	=> \$opt_f,
);

if ($opt_v) {
	print_revision($progname,"\$Revision: $revision \$");
	exit $ERRORS{'OK'};
}

if ($opt_h) { print_help(); exit $ERRORS{'OK'}; }

($opt_l) || ($opt_l = shift) || usage("Use -h for more info\n");
$remotehost=$opt_l;

my $program='check_syslog: ';

my $message=sprintf("Nagios Check -=- %d",rand(2**32));

$Sys::Syslog::host=$remotehost;

setlogsock('udp');

# Because of "The functions openlog(), syslog() and closelog() return the undefined value." I couldn't check for	#
# openlog errors, so if nagios cant connect the syslog-ng server the service state will be "UNKNOWN"			#

unless ( openlog($program,'nowait','user') ) {
	print "CRITICAL: Cant connect to syslog.\n";
	exit $ERRORS{'CRITICAL'};
}

syslog('info',$message);
closelog;

# wait a little to let syslog write to disk
sleep(1);

if ( defined($opt_f) ) {
	$filename=$opt_f;
} else {
	$filename='/var/log/nagios3/check_syslog';
}

unless ( open(FILE,"< $filename") ) {
	print"WARNING: Cant open file: $!\n";
	exit $ERRORS{'WARNING'};
}

while(my $line = <FILE>){
	if ($line =~ /$message$/ ){
		print "SYSLOG OK: Message sent and arrived.\n";
		exit $ERRORS{'OK'};
	}
}

close(FILE);

print "CRITICAL\n";
exit $ERRORS{'CRITICAL'};

sub print_usage () {
	print "Usage: $progname -l <logserver ip/name> [-f <logfile>]\n";
}

sub print_help () {
	print_revision($progname,"\$Revision: $revision \$");
	print "\nPerl check logserver through UDP\n";

	print_usage();

	print "

-v, --version
	Version of this script
-h, --help
	Help (this message)
-l, --loghost=ip/name
	Logserver's IP address or Hostname
-f, --logfile=filename
	Logfile path

";

#	support();

}

# Return values
# UNKNOWN	= -1
# OK		= 0
# WARNING	= 1
# CRITICAL	= 2

