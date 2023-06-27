# Networking

Ipsec tunnel config

```bash
conn Tunnel1
        authby=secret
        auto=start
        left=%defaultroute
        leftid=18.213.246.33
        right=34.224.162.50
        type=tunnel
        ikelifetime=8h
        keylife=1h
        phase2alg=aes_gcm
        ike=aes256-sha2_256;dh14
        keyingtries=%forever
        keyexchange=ike
        leftsubnet=10.10.0.0/16
        rightsubnet=10.0.0.0/14
        dpddelay=10
        dpdtimeout=30
        dpdaction=restart_by_peer
```

Flowlog iam policy

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    }
  ]
}   
```

```bash
yum install iperf3 -y

iperf3 -s

iperf3 -c 10.1.0.125 -P 2 -t 30^
```


Flow log Cloudwatch query

```bash
fields @timestamp, @message, @logStream, @log
| sort @timestamp desc
| limit 20
```

DNS Server Config

```bash
options {
  directory       "/var/named";
  dump-file       "/var/named/data/cache_dump.db";
  statistics-file "/var/named/data/named_stats.txt";
  memstatistics-file "/var/named/data/named_mem_stats.txt";
  recursing-file  "/var/named/data/named.recursing";
  secroots-file   "/var/named/data/named.secroots";

  recursion yes;

  allow-query { any; };

  dnssec-enable no;
  dnssec-validation no;

  bindkeys-file "/etc/named.root.key";

  managed-keys-directory "/var/named/dynamic";

  pid-file "/run/named/named.pid";
  session-keyfile "/run/named/session.key";

  forwarders {
          169.254.169.253;
  };
  forward first;
};

logging {
  channel default_debug {
        file "data/named.run";
        severity dynamic;
  };
};


zone "." IN {
        type hint;
        file "named.ca";
};

zone "kloudops.corp" IN {
        type master;
        file "/etc/named/example.corp";
        allow-update { none; };
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

/etc/named/example.corp

```bash
$ORIGIN kloudops.corp.
@                      3600 SOA   ns.kloudops.corp. (
                              zone-admin.kloudops.corp.     ; address of responsible party
                              2020050701                 ; serial number
                              3600                       ; refresh period
                              600                        ; retry period
                              604800                     ; expire time
                              1800                     ) ; minimum ttl
                      86400 NS    ns1.kloudops.corp.
myapp                    60 IN A  172.16.10.174
ns1                      60 IN A  172.16.10.36
```

```bash
aws ec2 describe-instances | grep "PrivateIpAddress" | cut -d '"' -f 4 | awk 'NR == 0 || NR % 4 == 0'
```

P1-tgw    10.8.0.0/16
DC1-tgw   10.4.0.0/16
DCS1-tgw  10.0.0.0/16
NP1-tgw   10.16.0.0/16
NP2-tgw   10.17.0.0/16 vpc-0473379e98f6f4a9b




