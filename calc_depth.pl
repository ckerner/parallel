#!/usr/bin/perl

use strict;
use Getopt::Long;
use POSIX qw( strftime );

sub get_options();
sub print_help();

$main::verbose = 0;
$main::counter = 0;
%main::depth;

sub get_options() {
    if( scalar(@ARGV) == 0 ) {
        print_help();
    }

    my $options = GetOptions( "v"      => sub { $main::verbose = 1 },
                              "help"   => sub { print_help() },
                              "d=s"    => \$main::directory,
                              "m=s"    => \$main::max_depth,
                            );
    return;
}

sub validate_options () {
    if( ! -d $main::directory ) { 
        print "Error: $main::directory does not exist.\n";
        exit 1;
    }
}

sub print_help() {
    my $basename = `basename $0`;
    chomp $basename;

    print <<EOH;

    Usage: $basename [ -v ] [ -m <MAX DEPTH> ] -d <DIRECTORY> 

    Option     Description
    -d DIR     The root directory you want to scan
    -m DEPTH   The maximum depth you want to recurse
    -v         Run in verbose mode
    --help     Print the help screen
EOH

    exit 0;
}

# Main Code Block
{
    get_options();

    validate_options();

    chdir $main::directory;

    if( ! $main::max_depth ) { open(INFIL, "find . -type d |"); }
    else { open(INFIL, "find . -maxdepth $main::max_depth -type d |"); }

    while(<INFIL>) {
       chomp;
       my $d = scalar( split(/\//,$_) );

       if( ! $main::depth{$d} ) { $main::depth{$d} = 1; }
       else               { $main::depth{$d} = $main::depth{$d} + 1; }

       if( $main::verbose ) {
           $main::count = $main::count + 1;
           if( ( $main::count % 500 ) == 0 ) {
               my $date = strftime("%Y-%m-%d %H:%M:%S", localtime());
               print "$date - Processed $main::count directories.\n";
           }
       }
    }
    close(INFIL);
    if( $main::verbose ) {
        my $date = strftime("%Y-%m-%d %H:%M:%S", localtime());
        print "$date - Processed $main::count directories.\n";
    }

    my $key;
    foreach $key ( sort keys %main::depth ) {
       printf("%5d \t %8d\n",$key,$main::depth{$key});
    }
}
