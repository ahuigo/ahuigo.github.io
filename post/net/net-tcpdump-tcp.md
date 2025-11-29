---
layout: page
title:	tcpdump tcp analysis
category: blog
description: 
private: true
---

# TCP Packets
参考`man tcpdump`找到 TCP Packets

The general format of a tcp protocol line is:

        src > dst: flags data-seqno ack window urgent options

       Src  and dst are the source and destination IP addresses and ports.  Flags are some
       combination of S (SYN), F (FIN), P (PUSH), R (RST), U (URG), W (ECN CWR),  E  (ECN-
       Echo)  or  `.' (ACK), or `none' if no flags are set.  Data-seqno describes the por-
       tion of sequence space covered by the data in this packet (see example below).  Ack
       is  sequence  number  of the next data expected the other direction on this connec-
       tion.  Window is the number of bytes of receive buffer space  available  the  other
       direction  on this connection.  Urg indicates there is `urgent' data in the packet.
       Options are tcp options enclosed in angle brackets (e.g., <mss 1024>).

       Src, dst and flags are always present.  The other fields depend on the contents  of
       the packet's tcp protocol header and are output only if appropriate.

       Here is the opening portion of an rlogin from host rtsg to host csam.
              rtsg.1023 > csam.login: S 768512:768512(0) win 4096 <mss 1024>
              csam.login > rtsg.1023: S 947648:947648(0) ack 768513 win 4096 <mss 1024>
              rtsg.1023 > csam.login: . ack 1 win 4096
              rtsg.1023 > csam.login: P 1:2(1) ack 1 win 4096
              csam.login > rtsg.1023: . ack 2 win 4096
              rtsg.1023 > csam.login: P 2:21(19) ack 1 win 4096
              csam.login > rtsg.1023: P 1:2(1) ack 21 win 4077
              csam.login > rtsg.1023: P 2:3(1) ack 21 win 4077 urg 1
              csam.login > rtsg.1023: P 3:4(1) ack 21 win 4077 urg 1
       The first line says that tcp port 1023 on rtsg sent a packet to port login on csam.
       The S indicates that the SYN flag was set.  The packet sequence number  was  768512
       and  it  contained  no  data.   (The  notation  is `first:last(nbytes)' which means
       `sequence numbers first up to but not including last which is nbytes bytes of  user
       data'.)  There was no piggy-backed ack, the available receive window was 4096 bytes
       and there was a max-segment-size option requesting an mss of 1024 bytes.

       Csam replies with a similar packet except it includes a piggy-backed ack for rtsg's
       SYN.   Rtsg  then acks csam's SYN.  The `.' means the ACK flag was set.  The packet
       contained no data so there is no data sequence number.  Note that the ack  sequence
       number  is  a small integer (1).  The first time tcpdump sees a tcp `conversation',
       it prints the sequence number from the packet.  On subsequent packets of  the  con-
       versation,  the  difference  between  the current packet's sequence number and this
       initial sequence number is printed.  This means that  sequence  numbers  after  the
       first  can  be  interpreted  as  relative byte positions in the conversation's data
       stream (with the first data byte each direction being  `1').   `-S'  will  override
       this feature, causing the original sequence numbers to be output.
       and  it  contained  no  data.   (The  notation  is `first:last(nbytes)' which means
       `sequence numbers first up to but not including last which is nbytes bytes of  user
       data'.)  There was no piggy-backed ack, the available receive window was 4096 bytes
       and there was a max-segment-size option requesting an mss of 1024 bytes.

       Csam replies with a similar packet except it includes a piggy-backed ack for rtsg's
       SYN.   Rtsg  then acks csam's SYN.  The `.' means the ACK flag was set.  The packet
       contained no data so there is no data sequence number.  Note that the ack  sequence
       number  is  a small integer (1).  The first time tcpdump sees a tcp `conversation',
       it prints the sequence number from the packet.  On subsequent packets of  the  con-
       Src  and dst are the source and destination IP addresses and ports.  Flags are some
       combination of S (SYN), F (FIN), P (PUSH), R (RST), U (URG), W (ECN CWR),  E  (ECN-
       Echo)  or  `.' (ACK), or `none' if no flags are set.  Data-seqno describes the por-
       tion of sequence space covered by the data in this packet (see example below).  Ack
       is  sequence  number  of the next data expected the other direction on this connec-
       tion.  Window is the number of bytes of receive buffer space  available  the  other
       direction  on this connection.  Urg indicates there is `urgent' data in the packet.
       Options are tcp options enclosed in angle brackets (e.g., <mss 1024>).

       Src, dst and flags are always present.  The other fields depend on the contents  of
       the packet's tcp protocol header and are output only if appropriate.

       Here is the opening portion of an rlogin from host rtsg to host csam.
              rtsg.1023 > csam.login: S 768512:768512(0) win 4096 <mss 1024>
              csam.login > rtsg.1023: S 947648:947648(0) ack 768513 win 4096 <mss 1024>
              rtsg.1023 > csam.login: . ack 1 win 4096
              rtsg.1023 > csam.login: P 1:2(1) ack 1 win 4096
              csam.login > rtsg.1023: . ack 2 win 4096
              rtsg.1023 > csam.login: P 2:21(19) ack 1 win 4096
              csam.login > rtsg.1023: P 1:2(1) ack 21 win 4077
              csam.login > rtsg.1023: P 2:3(1) ack 21 win 4077 urg 1
              csam.login > rtsg.1023: P 3:4(1) ack 21 win 4077 urg 1
       The first line says that tcp port 1023 on rtsg sent a packet to port login on csam.
       The S indicates that the SYN flag was set.  The packet sequence number  was  768512
       and  it  contained  no  data.   (The  notation  is `first:last(nbytes)' which means
       `sequence numbers first up to but not including last which is nbytes bytes of  user
       data'.)  There was no piggy-backed ack, the available receive window was 4096 bytes
       and there was a max-segment-size option requesting an mss of 1024 bytes.

       Csam replies with a similar packet except it includes a piggy-backed ack for rtsg's
       SYN.   Rtsg  then acks csam's SYN.  The `.' means the ACK flag was set.  The packet
       contained no data so there is no data sequence number.  Note that the ack  sequence
       number  is  a small integer (1).  The first time tcpdump sees a tcp `conversation',
       it prints the sequence number from the packet.  On subsequent packets of  the  con-
       versation,  the  difference  between  the current packet's sequence number and this
       initial sequence number is printed.  This means that  sequence  numbers  after  the
       first  can  be  interpreted  as  relative byte positions in the conversation's data
       stream (with the first data byte each direction being  `1').   `-S'  will  override
       this feature, causing the original sequence numbers to be output.

       On  the  6th line, rtsg sends csam 19 bytes of data (bytes 2 through 20 in the rtsg
       -> csam side of the conversation).  The PUSH flag is set in the packet.  On the 7th
       line,  csam  says  it's received data sent by rtsg up to but not including byte 21.
       Most of this data is apparently sitting in the socket buffer since  csam's  receive
       window  has  gotten  19 bytes smaller.  Csam also sends one byte of data to rtsg in
       this packet.  On the 8th and 9th lines, csam sends two bytes of urgent, pushed data
       to rtsg.

       If  the  snapshot was small enough that tcpdump didn't capture the full TCP header,
       it interprets as much of the header as it can and then reports ``[|tcp]'' to  indi-
       cate the remainder could not be interpreted.  If the header contains a bogus option
       (one with a length that's either too small or beyond the end of the  header),  tcp-
       dump  reports it as ``[bad opt]'' and does not interpret any further options (since
       it's impossible to tell where they start).  If the header length indicates  options
       are  present but the IP datagram length is not long enough for the options to actu-
       ally be there, tcpdump reports it as ``[bad hdr length]''.

       Capturing TCP packets with particular flag combinations (SYN-ACK, URG-ACK, etc.)

       There are 8 bits in the control bits section of the TCP header:

              CWR | ECE | URG | ACK | PSH | RST | SYN | FIN

       Let's assume that we want to watch packets used in establishing a  TCP  connection.
       Recall  that  TCP uses a 3-way handshake protocol when it initializes a new connec-
       tion; the connection sequence with regard to the TCP control bits is

              1) Caller sends SYN
              2) Recipient responds with SYN, ACK
              3) Caller sends ACK

       Now we're interested in capturing packets that have only the SYN bit set (Step  1).
       Note  that  we  don't want packets from step 2 (SYN-ACK), just a plain initial SYN.
       What we need is a correct filter expression for tcpdump.

       Recall the structure of a TCP header without options:

        0                            15                              31
       -----------------------------------------------------------------
       |          source port          |       destination port        |
       -----------------------------------------------------------------
       |                        sequence number                        |
       -----------------------------------------------------------------
       |                     acknowledgment number                     |
       -----------------------------------------------------------------
       |  HL   | rsvd  |C|E|U|A|P|R|S|F|        window size            |
       -----------------------------------------------------------------
       |         TCP checksum          |       urgent pointer          |
       -----------------------------------------------------------------

       A TCP header usually holds 20 octets of data,  unless  options  are  present.   The
       first  line  of the graph contains octets 0 - 3, the second line shows octets 4 - 7
       etc.

       Starting to count with 0, the relevant TCP control bits are contained in octet 13:

        0             7|             15|             23|             31
       ----------------|---------------|---------------|----------------
       |  HL   | rsvd  |C|E|U|A|P|R|S|F|        window size            |
       ----------------|---------------|---------------|----------------
       |               |  13th octet   |               |               |

       Let's have a closer look at octet no. 13:

                       |               |
                       |---------------|
                       |C|E|U|A|P|R|S|F|
                       |---------------|
                       |7   5   3     0|

       These are the TCP control bits we are interested in.  We have numbered the bits  in
       this  octet  from  0 to 7, right to left, so the PSH bit is bit number 3, while the
       URG bit is number 5.

       Recall that we want to capture packets with only SYN set.  Let's see  what  happens
       to octet 13 if a TCP datagram arrives with the SYN bit set in its header:

                       |C|E|U|A|P|R|S|F|
                       |---------------|
                       |0 0 0 0 0 0 1 0|
                       |---------------|
                       |7 6 5 4 3 2 1 0|

       Looking at the control bits section we see that only bit number 1 (SYN) is set.

       Assuming  that  octet number 13 is an 8-bit unsigned integer in network byte order,
       the binary value of this octet is

              00000010

       and its decimal representation is

          7     6     5     4     3     2     1     0
       0*2 + 0*2 + 0*2 + 0*2 + 0*2 + 0*2 + 1*2 + 0*2  =  2

       We're almost done, because now we know that if only SYN is set, the  value  of  the
       13th  octet in the TCP header, when interpreted as a 8-bit unsigned integer in net-
       work byte order, must be exactly 2.

       This relationship can be expressed as
              tcp[13] == 2

       We can use this expression as the filter for tcpdump  in  order  to  watch  packets
       which have only SYN set:
              tcpdump -i xl0 tcp[13] == 2

       The  expression  says  "let the 13th octet of a TCP datagram have the decimal value
       2", which is exactly what we want.

       Now, let's assume that we need to capture SYN packets, but we don't care if ACK  or
       any other TCP control bit is set at the same time.  Let's see what happens to octet
       13 when a TCP datagram with SYN-ACK set arrives:

            |C|E|U|A|P|R|S|F|
            |---------------|
            |0 0 0 1 0 0 1 0|
            |---------------|
            |7 6 5 4 3 2 1 0|

       Now bits 1 and 4 are set in the 13th octet.  The binary value of octet 13 is

                   00010010

       which translates to decimal

          7     6     5     4     3     2     1     0
       0*2 + 0*2 + 0*2 + 1*2 + 0*2 + 0*2 + 1*2 + 0*2   = 18

       Now we can't just use 'tcp[13] == 18' in the  tcpdump  filter  expression,  because
       that would select only those packets that have SYN-ACK set, but not those with only
       SYN set.  Remember that we don't care if ACK or any other control  bit  is  set  as
       long as SYN is set.

       In order to achieve our goal, we need to logically AND the binary value of octet 13
       with some other value to preserve the SYN bit.  We know that we want SYN to be  set
       in  any  case,  so  we'll logically AND the value in the 13th octet with the binary
       value of a SYN:


                 00010010 SYN-ACK              00000010 SYN
            AND  00000010 (we want SYN)   AND  00000010 (we want SYN)
                 --------                      --------
            =    00000010                 =    00000010

       We see that this AND operation delivers the same result regardless whether  ACK  or
       We see that this AND operation delivers the same result regardless whether  ACK  or
       another  TCP  control  bit  is set.  The decimal representation of the AND value as
       well as the result of this operation is 2 (binary 00000010), so we  know  that  for
       packets with SYN set the following relation must hold true:

              ( ( value of octet 13 ) AND ( 2 ) ) == ( 2 )

       This points us to the tcpdump filter expression
                   tcpdump -i xl0 'tcp[13] & 2 == 2'

       Some offsets and field values may be expressed as names rather than as numeric val-
       ues. For example tcp[13] may be replaced with tcp[tcpflags]. The following TCP flag
       field values are also available: tcp-fin, tcp-syn, tcp-rst, tcp-push, tcp-act, tcp-
       urg.

       This can be demonstrated as:
                   tcpdump -i xl0 'tcp[tcpflags] & tcp-push != 0'

       Note that you should use single quotes or a backslash in the expression to hide the
       AND ('&') special character from the shell.

                 --------                      --------
            =    00000010                 =    00000010

       We see that this AND operation delivers the same result regardless whether  ACK  or
       another  TCP  control  bit  is set.  The decimal representation of the AND value as
       well as the result of this operation is 2 (binary 00000010), so we  know  that  for
       packets with SYN set the following relation must hold true:

              ( ( value of octet 13 ) AND ( 2 ) ) == ( 2 )

       This points us to the tcpdump filter expression
                   tcpdump -i xl0 'tcp[13] & 2 == 2'

       Some offsets and field values may be expressed as names rather than as numeric val-
       ues. For example tcp[13] may be replaced with tcp[tcpflags]. The following TCP flag
       field values are also available: tcp-fin, tcp-syn, tcp-rst, tcp-push, tcp-act, tcp-
       urg.

       This can be demonstrated as:
                   tcpdump -i xl0 'tcp[tcpflags] & tcp-push != 0'

       Note that you should use single quotes or a backslash in the expression to hide the
       AND ('&') special character from the shell.

       UDP Packets

       UDP format is illustrated by this rwho packet:
              actinide.who > broadcast.who: udp 84
       This  says  that  port who on host actinide sent a udp datagram to port who on host
       broadcast, the Internet broadcast address.  The packet contained 84 bytes  of  user
       data.

       Some  UDP  services are recognized (from the source or destination port number) and
       the higher level protocol information printed.  In particular, Domain Name  service
       requests (RFC-1034/1035) and Sun RPC calls (RFC-1050) to NFS.

# Tcp example
```bash
$ sudo tcpdump -i any -AXn  'port 8089'
16:19:35.769796 lo    In  IP 127.0.0.1.3634 > 127.0.0.1.8089: Flags [S], seq 3620587497, win 43690, options [mss 65495,nop,nop,sackOK,nop,wscale 9], length 0
        0x0000:  4500 0034 eaca 4000 4006 51f7 7f00 0001  E..4..@.@.Q.....
        0x0010:  7f00 0001 0e32 1f99 d7cd c7e9 0000 0000  .....2..........
        0x0020:  8002 aaaa fe28 0000 0204 ffd7 0101 0402  .....(..........
        0x0030:  0103 0309                                ....
16:19:35.769822 lo    In  IP 127.0.0.1.8089 > 127.0.0.1.3634: Flags [S.], seq 957276460, ack 3620587498, win 43690, options [mss 65495,nop,nop,sackOK,nop,wscale 9], length 0
        0x0000:  4500 0034 0000 4000 4006 3cc2 7f00 0001  E..4..@.@.<.....
        0x0010:  7f00 0001 1f99 0e32 390e e12c d7cd c7ea  .......29..,....
        0x0020:  8012 aaaa fe28 0000 0204 ffd7 0101 0402  .....(..........
        0x0030:  0103 0309                                ....
16:19:35.769836 lo    In  IP 127.0.0.1.3634 > 127.0.0.1.8089: Flags [.], ack 1, win 86, length 0
        0x0000:  4500 0028 eacb 4000 4006 5202 7f00 0001  E..(..@.@.R.....
        0x0010:  7f00 0001 0e32 1f99 d7cd c7ea 390e e12d  .....2......9..-
        0x0020:  5010 0056 fe1c 0000                      P..V....
16:19:35.769885 lo    In  IP 127.0.0.1.3634 > 127.0.0.1.8089: Flags [P.], seq 1:82, ack 1, win 86, length 81
        0x0000:  4500 0079 eacc 4000 4006 51b0 7f00 0001  E..y..@.@.Q.....
        0x0010:  7f00 0001 0e32 1f99 d7cd c7ea 390e e12d  .....2......9..-
        0x0020:  5018 0056 fe6d 0000 4745 5420 2f31 3233  P..V.m..GET./123
        0x0030:  2048 5454 502f 312e 310d 0a48 6f73 743a  .HTTP/1.1..Host:
        0x0040:  206c 6f63 616c 686f 7374 3a38 3038 390d  .localhost:8089.
        0x0050:  0a55 7365 722d 4167 656e 743a 2063 7572  .User-Agent:.cur
        0x0060:  6c2f 372e 3831 2e30 0d0a 4163 6365 7074  l/7.81.0..Accept
        0x0070:  3a20 2a2f 2a0d 0a0d 0a                   :.*/*....
16:19:35.769890 lo    In  IP 127.0.0.1.8089 > 127.0.0.1.3634: Flags [.], ack 82, win 86, length 0
        0x0000:  4500 0028 4f14 4000 4006 edb9 7f00 0001  E..(O.@.@.......
        0x0010:  7f00 0001 1f99 0e32 390e e12d d7cd c83b  .......29..-...;
        0x0020:  5010 0056 fe1c 0000                      P..V....
```