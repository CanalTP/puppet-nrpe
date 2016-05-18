#!/usr/bin/perl -w
# Nagios plugin to check pgpool2 status
# Author: Pravin Rane
# Email: pravin.rane@gmail.com
# Command: # pcp_node_info 10 IP  9898  username password 0
# Output: postgres-db 5432 2 nan
#           |             |   |  |
#           |             |   |  +- Load balancer weight
#           |             |   +---- Status: 1>Node is up. No connections yet. 2>Node is up. Connections are pooled. 3>Node is down.
#           |             +-------- Port Number
#           +---------------------- DB Hostname
# Config: Set login credentials in /etc/pcp.conf
use strict;
use Getopt::Long;
use vars qw($opt_V $opt_h $opt_H $opt_C $PROGNAME $opt_t $opt_n $opt_u $opt_p);
use lib "/usr/lib/nagios/plugins/" ;
use utils qw(%ERRORS &print_revision &support &usage);

$PROGNAME = "check_pgpool2.pl";
my $state = "unknown";
my $status = 3 ;
sub print_help ();
sub print_usage ();

$ENV{'PATH'}='';
$ENV{'BASH_ENV'}='';
$ENV{'ENV'}='';

Getopt::Long::Configure('bundling');
GetOptions
    ("V"   => \$opt_V, "version"        => \$opt_V,
     "h"   => \$opt_h, "help"           => \$opt_h,
     "H=s" => \$opt_H, "hostname=s"     => \$opt_H,
     "t=i" => \$opt_t, "timeout=i"      => \$opt_t,
     "n=i" => \$opt_n, "nodeid=i"       => \$opt_n,
     "u=s" => \$opt_u, "username=s"     => \$opt_u,
     "p=s" => \$opt_p, "password=s"     => \$opt_p);

if ($opt_V) {
                print_revision($PROGNAME,'$Revision: 1.0 $');
                exit $ERRORS{$state};
}

if ($opt_h) {print_help(); exit $ERRORS{$state};}

($opt_H) || usage("Host name/address not specified\n");
($opt_u) || usage("Username not specified\n");
($opt_p) || usage ("Password not specified\n");
my $host = $1 if ($opt_H =~ /([-.A-Za-z0-9]+)/);
($host) || usage("Invalid host: $opt_H\n");
($opt_t) || ($opt_t = 5);
($opt_n) || ($opt_n = 0);

my $etat_node;
my $node;
my $out =  `/usr/bin/pcp_node_info $opt_t $opt_H 9898 $opt_u $opt_p $opt_n` || exit $ERRORS{$state};
if ( $? == 0 ) {
        chomp $out;
        my ($DB, $PORT, $STAT, $W) = split(/\s+/,$out);
        if ($STAT == 2) {
                $state = "ok";
                $status = 0 ;
                $etat_node = "Le nœud est en ligne, et les connexions sont pooles.";
                $node = $DB;
        }
        elsif ($STAT == 3) {
                $state = "critical";
                $status = 2 ;
                $etat_node = "Le nœud est arrete.";
                $node = $DB;

        }
        elsif ($STAT == 1) {
                $state = "warning";
                $status = 1 ;
                $etat_node = "Le nœud est en ligne, mais aucune connexion n est encore faite dessus.";
                $node = $DB;
        }
} else {
        chomp $out;
        $state = "critical" ;
}
print $state.": ".$node." - ".$etat_node."\n";
exit ($status);

sub print_usage () {
        print "Usage: $PROGNAME -H <host> [-t <timeout>] -u <username> -p <password> [-n <nodeid>]\n";
}

sub print_help () {
        print_revision($PROGNAME,'$Revision: 0.5 $');
                print "Copyright (c) 2012 Pravin Rane
Licence : GPL - http://www.fsf.org/licenses/gpl.txt
This plugin checks pgpool2 status.

";
        print_usage();
        print "
-H, --hostname=HOST
        Name or IP address of host to check
-t --timeout=seconds default 5
        timeout value in seconds. PCP disconnects if
        pgpool-II does not respond in this many seconds.
-n --nodeid = default 0
-u --username=PCP username
-p --password=PCP password

";
        support();
}

