# Finding Authoritative Name Servers for a Domain

I needed to do this when changing my DNS from `domain.com` to LuaDNS. When
changing name servers, the domain name provider needs to inform the registrar
about the new NS records, so that the zone files in the registrar's
authoritative zone files can be updated. This was just a check to verify that
everything went smoothly.

First, let's make sure that `luadns.net` appears to be authoritative over my
domain:

```
[edtwardy@hackbook ~]$ dig +nssearch ethantwardy.com
SOA ns1.luadns.net. hostmaster.luadns.com. 1713480614 1200 120 604800 3600 from server 185.142.218.3 in 20 ms.
SOA ns1.luadns.net. hostmaster.luadns.com. 1713480614 1200 120 604800 3600 from server 185.142.218.4 in 21 ms.
SOA ns1.luadns.net. hostmaster.luadns.com. 1713480614 1200 120 604800 3600 from server 185.142.218.1 in 24 ms.
SOA ns1.luadns.net. hostmaster.luadns.com. 1713480614 1200 120 604800 3600 from server 185.142.218.2 in 25 ms.
SOA ns1.luadns.net. hostmaster.luadns.com. 1713480614 1200 120 604800 3600 from server 2001:67c:25a0::2 in 120 ms.
SOA ns1.luadns.net. hostmaster.luadns.com. 1713480614 1200 120 604800 3600 from server 2001:67c:25a0::1 in 121 ms.
SOA ns1.luadns.net. hostmaster.luadns.com. 1713480614 1200 120 604800 3600 from server 2001:67c:25a0::4 in 122 ms.
SOA ns1.luadns.net. hostmaster.luadns.com. 1713480614 1200 120 604800 3600 from server 2001:67c:25a0::3 in 126 ms.
```

As a sanity check, let's find the authoritative name servers over the
top-level domain (TLD) and verify their records point to LuaDNS:

```
[edtwardy@hackbook ~]$ dig +norecurse +noall +authority ethantwardy.com SOA
com.			171963	IN	NS	j.gtld-servers.net.
com.			171963	IN	NS	f.gtld-servers.net.
com.			171963	IN	NS	g.gtld-servers.net.
com.			171963	IN	NS	h.gtld-servers.net.
com.			171963	IN	NS	m.gtld-servers.net.
com.			171963	IN	NS	l.gtld-servers.net.
com.			171963	IN	NS	i.gtld-servers.net.
com.			171963	IN	NS	a.gtld-servers.net.
com.			171963	IN	NS	d.gtld-servers.net.
com.			171963	IN	NS	k.gtld-servers.net.
com.			171963	IN	NS	c.gtld-servers.net.
com.			171963	IN	NS	e.gtld-servers.net.
com.			171963	IN	NS	b.gtld-servers.net.
[edtwardy@hackbook ~]$ dig @l.gtld-servers.net ethantwardy.com

; <<>> DiG 9.16.48 <<>> @l.gtld-servers.net ethantwardy.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 48587
;; flags: qr rd; QUERY: 1, ANSWER: 0, AUTHORITY: 4, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;ethantwardy.com.		IN	A

;; AUTHORITY SECTION:
ethantwardy.com.	172800	IN	NS	ns2.luadns.net.
ethantwardy.com.	172800	IN	NS	ns1.luadns.net.
ethantwardy.com.	172800	IN	NS	ns3.luadns.net.
ethantwardy.com.	172800	IN	NS	ns4.luadns.net.

;; Query time: 71 msec
;; SERVER: 2001:500:d937::30#53(2001:500:d937::30)
;; WHEN: Fri Apr 19 07:24:45 CDT 2024
;; MSG SIZE  rcvd: 126
```
