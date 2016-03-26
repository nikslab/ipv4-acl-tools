# ipv4-acl-tools

If you are working with IPv4 ACLs on routers or in DNS views, you might find these tools useful.

<b>optimizeACL.pl</b> is the creme of this crop, and the main reason why it was written.  It will take take a very large ACL (for example IP allocations by one of the NICs) and create an optimized, smaller ACL (= faster parsing by router or DNS server).

All scripts work like filters so you can pipe through them.  See examples below how to use.  All the functions are in ACL.pm so you can add a few more tools yourself using them.

The key to solving this problem was the concept that you can convert an IP number to an integer (0.0.0.0 = 0, 255.255.255.255 = 4,228,250,625), what's called a "long IP represenation."  This way you convert a subnet to an array of integers.  It is then easy to count IPs or sort the ACL.  To optimize you merge two arrays, and then convert the range back to a subnet.  Repeat.

<pre>
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat *.acl</b>
192.168.1.0/24;
10.10.10.0/24;
10.10.10.0/24;
10.10.0.0/16;
10.73.10.0/16;
10.0.0.0/8;
10.73.10.0/24;
192.168.0.0/31;
10.0.0.0/8;
14.14.14.5/12;
0.1.2.3/8;
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat *.acl | ./optimizeACL.pl</b>
0.1.2.3/8;
10.0.0.0/8;
14.14.14.5/12;
192.168.0.0/31;
192.168.1.0/24;
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat sample1.acl | ./countIP.pl</b></i>
Total IPs: 16909056
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat sample2.acl | ./countIP.pl</b>
Total IPs: 258
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat sample3.acl | ./countIP.pl</b>
Total IPs: 16777216
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat sample4.acl | ./countIP.pl</b>
Total IPs: 17825792
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat *.acl | ./countIP.pl</b> 
Total IPs: 51512322
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat *.acl | ./optimizeACL.pl | ./countIP.pl</b> 
Total IPs: 34603266
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat sample1.acl</b>
192.168.1.0/24;
10.10.10.0/24;
10.10.10.0/24;
10.10.0.0/16;
10.73.10.0/16;
10.0.0.0/8;
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>cat sample1.acl | ./sortACL.pl</b>
10.0.0.0/8;
10.10.0.0/16;
10.10.10.0/24;
10.10.10.0/24;
10.73.10.0/16;
192.168.1.0/24;
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$</i> <b>./range2ACL.pl 10.0.0.0 10.73.1.0</b>
10.0.0.0/10;
10.64.0.0/13;
10.72.0.0/16;
10.73.0.0/24;
10.73.1.0/32;
</pre>
