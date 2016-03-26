package ACL;

#############################################################################
#                                                                           #
# Subroutines for ACL optimization                                          #
#                                                                           #
# Nik Stankovic, Version 1.0 on April 28, 2010                              #
#                                                                           #
#############################################################################

use Exporter;
@ISA = ("Exporter");
@EXPORT = qw( &aclOptimize &aclSort &isValidSubnet &subnetStartStop &range2ACL &maxCIDR &dec2bin @bin2dec &subnetSize &subnetIntersect &highestPower2 &ip2long &long2ip );


sub aclOptimize { # ( @ACL )

    my( @ACL ) = @_;

    @new_optimized = aclSort( @ACL );
    my $pass = 0;
    my $changes = 1;
    while ( $changes ) {
        $pass++;
        $changes = 0;
        my @optimized = @new_optimized;
        @new_optimized = ();
        
        for( my $c=0; $c <= $#optimized; $c++ ) {
            
            if( isValidSubnet( $optimized[$c] ) && isValidSubnet( $optimized[$c+1] ) ) {
                my( $start1, $stop1 ) = subnetStartStop( $optimized[$c] );
                my( $start2, $stop2 ) = subnetStartStop( $optimized[$c+1] );
               
                # Identical / remove by skipping
                if( ( $start1 == $start2 ) && ( $stop1 == $stop2 ) ) {
                    push( @new_optimized, $optimized[$c] );
                    $changes++;
                    $c++;
                }
                
                # They are not identical.  If second is contained in first, skip the second one
                elsif( subnetIntersect( $optimized[$c], $optimized[$c+1] ) == subnetSize( $optimized[$c+1] ) )
                {
                    push( @new_optimized, $optimized[$c] );
                    $changes++;
                    $c++;
                }
                
                # If first is contained in second, just skip
                elsif( subnetIntersect( $optimized[$c], $optimized[$c+1] ) == subnetSize( $optimized[$c] ) )
                {
                    $changes++;
                    #$c++;
                }
                
                # If they are consecutive... try to rewrite them
                elsif( $stop1 == $start2 ) {
                    my @new_ACL = range2ACL( $start1, ( $stop2-1 ) );
                    # If we got more or less than 2 subnets (what we started with), replace...
                    if( scalar( @new_ACL ) != 2 ) { 
                       push( @new_optimized, @new_ACL );
                       $changes++;
                       $c++;
                    }

                    # if not, just move on
                    else { push( @new_optimized, $optimized[$c] ) }
            
                }

                # If none of the above, just move on
                else {
                    push( @new_optimized, $optimized[$c] );
                }
                
            }
            else { 
                if( isValidSubnet( $optimized[$c] ) ) { push( @new_optimized, $optimized[$c] ) }
            }
        }
    }
    
    return @new_optimized;
    
}


sub aclSort { # ( @ACL )
# Sorts an ACL in ascending order

    my( @ACL ) = @_;
    my @ordered = sort { ip2long( substr( $a, 0, index( $a, "/" ) ) ) <=> ip2long( substr( $b, 0, index( $b, "/" ) ) ) } @ACL;
    return @ordered;
}


sub isValidSubnet { # ( $subnet )
# Returns 1 if (probably) valid subnet, returns 0 if definitely not 
    my( $subnet ) = @_;
    my $result = 0;
    if( $subnet =~ "\." ) { $result++ }
    if( $subnet =~ "\/" ) { $result++ }
    if( $subnet =~ "\;" ) { $result++ }
    if ( $result != 3 ) { $result = 0 } else { $result = 1 }
    return $result;
}


sub subnetStartStop { # ( $subnet )
# Given a subnet, will return start and stop IPs (long representation)

    my( $subnet ) = @_;

    if( isValidSubnet( $subnet ) ) {
        my( $start, $stopCIDR ) = split( /\//, $subnet );
        chomp( $stopCIDR ); chop( $stopCIDR );
        my $startLong = ip2long( $start );
        my $stop = $startLong + 2**( 32 - $stopCIDR );
       return( $startLong, $stop );
    }
    else { return( -1, -1 ) }
}


sub range2ACL { # ( $start_ip_long, $stop_ip_long )
# Takes a consecutive range of IPs in long representation and
# converts it to the shortes possible ACL in CIDR representation
# Returns the ACL as an array of strings

    my( $start_ip_long, $stop_ip_long ) = @_;
    my $count = $stop_ip_long - $start_ip_long;
    my @acl = ();
    if( $count >= 0 ) {
        my $remainder = $count + 1;
        while( $remainder > 0 ) {
            my $theoretical = maxCIDR( $start_ip_long ); 
            my $available = 32 - highestPower2( $remainder );    
            my $CIDR = $available;  # assume

            if( $available < $theoretical ) { $CIDR = $theoretical }
            my $ip = long2ip( $start_ip_long );
            push( @acl, "$ip/$CIDR;\n" );
            my $CIDR_count = 2**( 32-$CIDR );
            $start_ip_long = $start_ip_long + $CIDR_count;
            $remainder = $remainder - $CIDR_count;
        }
    }
    #else { print "Error in parameters $start_ip_long, $stop_ip_long\n"; }
    return @acl;

}


sub maxCIDR { # ( $ip_long )
# Given an IP number (in long representation) returns the highest THEORETICAL CIDR subnet
    my( $ip_long ) = @_;
    my $result = ( 32 - index( reverse( dec2bin( $ip_long ) ), "1" ) );
    if( $result == 33 ) { $result = 0 }; # special case for 0, where there are no 1s, so index returns -1
    return $result;
}


sub subnetSize { # ( $subnet )
# Returns the size of the subnet in number of IPs
    my( $subnet ) = @_;
    my $result = 0;
    if( isValidSubnet( $subnet ) ) {
        my( $ip, $CIDR ) = split( /\//, $subnet );
        chomp( $CIDR ); chop( $CIDR );
        $result = 2**( 32 - $CIDR );
    }
    return $result;
}


sub subnetIntersect { # ( $subnet1, $subnet2 )
# Returns the number of IPs in intersection between two subnets
    my( $subnet1, $subnet2 ) = @_;
    my $result = 0;
    my( $start1, $stop1 ) = subnetStartStop( $subnet1 );
    my( $start2, $stop2 ) = subnetStartStop( $subnet2 );
    if( $start2 >= $start1 ) {
        if( $stop2 <= $stop1 ) {
            # $subnet2 is fully contained in $subnet1
            $result = $stop2 - $start2;
        }
        else {
            $result = $stop1 - $start2;
        }
    }
    else {
        if( $stop2 >= $stop1 ) {
            # subnet1 is fully contained in $subnet2
            $result = $stop1 - $start1;
        }
        else {
            $result = $stop2 - $start1;
        }
    }
    
    return $result;
}


sub dec2bin { # ( $dec )
# Decimal to binary conversion.
# Swiped this from the Internet somewhere but don't remember where anymore
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}


sub bin2dec { # ( $bin )
# Binary to decimal conversion.
# Swiped this from the Internet somewhere but don't remember where anymore
    my( $bin ) = @_;
    return oct("0b".$bin);
}


sub highestPower2 { # ( $number )
# Returns the highest power of 2 not exceeding the number
# For example, if number is 12, result is 3, because 2^3 < 12 and 2^4 > 12
# Another example: if number is 16, result is 4, because 2^4 = 16

    my( $value ) = @_;

    my $power = 0;
    while( 2**$power < $value ) { $power++ }
    if( 2**$power > $value ) { $power-- } # if we overshot
    return $power;
}


sub ip2long { # ( $ip_address )
# Given an IP in standard octet representation, returns the consecutive order IP number
# Example: 0.0.0.0 return 0, 0.0.0.1 returns 1, 0.0.0.2 returns 2 etc

    my ( $ip ) = @_;

    my( @octets, $octet, $ip_long, $number_convert );

    @octets = split( /\./, $ip );
    $ip_long = 0;
    foreach $octet( @octets ) {
        $ip_long <<= 8;
        $ip_long |= $octet;
    }

    return $ip_long;

}


sub long2ip { # ( $ip_long )
# Given an IP in long representation, returns an IP in standard octet representation
# Example: 0 returns 0.0.0.0, 1 returns 0.0.0.1, 2 returns 0.0.0.2 etc

    my( $ip_long ) = @_;

    my( @octets, $i, $ip_address, $ip_long_display, $number_convert );
    $ip_long_display = $ip_long;
    for( $i = 3; $i >= 0; $i--) {
        $octets[ $i ] = ( $ip_long & 0xFF );
        $ip_long >>= 8;  
    }

    $ip = join('.', @octets);

    return $ip;

}

1;

#################################### END ####################################
