#!/usr/bin/perl

#############################################################################
#                                                                           #
# range2ACL.pl                                                              #
#                                                                           #
# Returns an ACL for an IP range given by two arguments (start, stop)       #
#                                                                           #
# Nik Stankovic, Version 1.0 on April 28, 2010                              #
#                                                                           #
#############################################################################

use ACL;

$start = ip2long( $ARGV[0] );
$stop = ip2long( $ARGV[1] );

if( $stop == 0 ) { $stop = $start }

if( $stop >= $start ) {
    @ACL = range2ACL( $start, $stop );
}
else { print "Bad arguments.\n"; }

print @ACL;

#################################### END ####################################

