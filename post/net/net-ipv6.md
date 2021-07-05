---
title: net ipv6
date: 2018-09-28
---
# ipv6
## tcp ipv6
参考unix 网络编程 page10

    #include "unp.h"
    int main(int argc, char **argv){
        int sockfd,n;
        char recvline[MAXLINE+1];
        struct sockaddr_in6 servaddr; //ipv6

        if(arc!=2)
            err_quit("usage: a.out <ipaddress>");

        if((sockfd = socket(AF_INET6, SOCK_STREAM, 0))<0)   //ipv6
            err_sys("socket error");

        bzero(&servaddr, sizeof(servaddr));
        servaddr.sin6_family = AF_INET6;    //ipv6
        servaddr.sin6_port = htons(13); /*daytime server*/
        if(inet_pton(AF_INET6, argv[1], &servaddr.sin6_addr)<=0)     // ipv6
            err_quit("inet_pton error for %s", argv[1]);

        if(connect(sockfd, (sockaddr *)&servaddr, sizeof(servaddr))<0)
            err_sys("connect error");

        while((n=read(sockfd, recvline, MAXLINE))>0){
            recvline[n] = 0; /*null terminate */
            if(fputs(recvline, stdout)==EOF)
                err_sys("fputs error");
        }
        if(n<0)
            err_sys("read error");

        exit(0)
    }
