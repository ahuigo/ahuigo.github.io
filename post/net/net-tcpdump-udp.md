---
layout: page
title:	tcpdump udp analysis
category: blog
description:
---
# UDP Packets
> 参考`man tcpdump`找到 UDP Packets

       UDP format is illustrated by this rwho packet:
              actinide.who > broadcast.who: udp 84
       This  says  that  port who on host actinide sent a udp datagram to port who on host
       broadcast, the Internet broadcast address.  The packet contained 84 bytes  of  user
       data.

       Some  UDP  services are recognized (from the source or destination port number) and
       the higher level protocol information printed.  In particular, Domain Name  service
       requests (RFC-1034/1035) and Sun RPC calls (RFC-1050) to NFS.

       UDP Name Server Requests

       (N.B.:The  following description assumes familiarity with the Domain Service proto-
       col described in RFC-1035.  If you are not familiar with the protocol, the  follow-
       ing description will appear to be written in greek.)

       Name server requests are formatted as
              src > dst: id op? flags qtype qclass name (len)
              h2opolo.1538 > helios.domain: 3+ A? ucbvax.berkeley.edu. (37)
       Host  h2opolo  asked  the  domain  server on helios for an address record (qtype=A)
       associated with the name ucbvax.berkeley.edu.  The query id was `3'.  The `+' indi-
       cates  the  recursion  desired  flag  was  set.  The query length was 37 bytes, not
       including the UDP and IP protocol headers.  The query operation was the normal one,
       Query,  so  the  op  field was omitted.  If the op had been anything else, it would
       have been printed between the `3' and the `+'.  Similarly, the qclass was the  nor-
       mal  one,  C_IN, and omitted.  Any other qclass would have been printed immediately
       after the `A'.

       A few anomalies are checked and may result  in  extra  fields  enclosed  in  square
       brackets:   If  a query contains an answer, authority records or additional records
       section, ancount, nscount, or arcount are printed as  `[na]',  `[nn]'  or   `[nau]'
       where  n  is the appropriate count.  If any of the response bits are set (AA, RA or
       rcode) or any of the `must be zero' bits are set in bytes two and three, `[b2&3=x]'
       is printed, where x is the hex value of header bytes two and three.

       UDP Name Server Responses

       Name server responses are formatted as
              src > dst:  id op rcode flags a/n/au type class data (len)
              helios.domain > h2opolo.1538: 3 3/3/7 A 128.32.137.3 (273)
              helios.domain > h2opolo.1537: 2 NXDomain* 0/1/0 (97)
       In  the  first  example,  helios  responds to query id 3 from h2opolo with 3 answer
       records, 3 name server records and 7 additional records.  The first  answer  record
       is  type A (address) and its data is internet address 128.32.137.3.  The total size
       of the response was 273 bytes, excluding UDP and IP headers.  The  op  (Query)  and
       response code (NoError) were omitted, as was the class (C_IN) of the A record.

       In the second example, helios responds to query 2 with a response code of non-exis-
       tent domain (NXDomain) with no answers, one name server and no  authority  records.
       The  `*'  indicates that the authoritative answer bit was set.  Since there were no
       answers, no type, class or data were printed.

       Other flag characters that might appear are `-' (recursion available, RA, not  set)
       and  `|'  (truncated  message, TC, set).  If the `question' section doesn't contain
       exactly one entry, `[nq]' is printed.