#!/usr/bin/perl

#############################################################################
#                                                                           #
# sortACL.pl                                                                #
#                                                                           #
# Shell script / filter reads in an ACL returns and returns it sorted by IP #
#                                                                           #
# Nik Stankovic, Version 1.0 on April 28, 2010                              #
#                                                                           #
#############################################################################

use ACL;

while ( <> ) {
    push( @ACL, $_ );    
}

@sorted = aclSort( @ACL );

foreach $element ( @sorted ) { print "$element" }

#################################### END ####################################