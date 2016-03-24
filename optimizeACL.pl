#!/usr/bin/perl

#############################################################################
#                                                                           #
# optimizeACL.pl                                                            #
#                                                                           #
# Will optimize an ACL                                                      #
# Works like a filter, taking an ACL on STDIN,                              #
# and printing the optimized ACL out on STDOUT                              #
#                                                                           #
# Nik Stankovic, Version 1.0 on April 28, 2010                              #
#                                                                           #
#############################################################################

use ACL;

while ( <> ) {
    push( @ACL, $_ );    
}

#print "Read in $#ACL records...\n";

@optimized_ACL = aclOptimize( @ACL );

foreach $a ( @optimized_ACL ) { print "$a" }

#################################### END ####################################



