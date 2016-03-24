#!/usr/bin/perl

#############################################################################
#                                                                           #
# countIP.pl                                                                #
#                                                                           #
# Shell script / filter reads in an ACL returns sum total number of IPs     #
#                                                                           #
# Nik Stankovic, Version 1.0 on April 28, 2010                              #
#                                                                           #
#############################################################################

use ACL;

$sum = 0;

while ( <> ) {
    if( isValidSubnet( $_ ) ) { $sum = $sum + subnetSize( $_ ) }
}

print "Total IPs: $sum\n";

#################################### END ####################################
