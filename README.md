# ACL-tools

If you are working with ACLs on routers or in DNS views, these few tools might be useful. 

<b>optimizeACL.pl</b> in particular will take take a very large ACL (for example IP allocations by country from one of the NICs) and create an optimized, smaller ACL (=faster parsing by router or DNS server).

All scripts work like filters so you can pipe through them.

<pre>
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$ <b>cat *.acl</b></i>
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
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$ <b>cat *.acl | ./optimizeACL.pl</b></i>
0.1.2.3/8;
10.0.0.0/8;
14.14.14.5/12;
192.168.0.0/31;
192.168.1.0/24;
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$ <b>cat sample1.acl | ./countIP.pl</b></i>
Total IPs: 16909056
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$ <b>cat sample2.acl | ./countIP.pl</b></i>
Total IPs: 258
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$ <b>cat sample3.acl | ./countIP.pl</b></i>
Total IPs: 16777216
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$ <b>cat sample4.acl | ./countIP.pl</b></i>
Total IPs: 17825792
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$ <b>cat sample1.acl</b></i>
192.168.1.0/24;
10.10.10.0/24;
10.10.10.0/24;
10.10.0.0/16;
10.73.10.0/16;
10.0.0.0/8;
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$ <b>cat sample1.acl | ./sortACL.pl</b></i>
10.0.0.0/8;
10.10.0.0/16;
10.10.10.0/24;
10.10.10.0/24;
10.73.10.0/16;
192.168.1.0/24;
<i>nik@nik-laptop:~/Dropbox/Lab/ACL$ <b>./range2ACL.pl 10.0.0.0 10.73.1.0</b></i>
10.0.0.0/10;
10.64.0.0/13;
10.72.0.0/16;
10.73.0.0/24;
10.73.1.0/32;
</pre>
