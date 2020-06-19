---
title: ldap
date: 2020-06-18
private: true
---
# ldap
## todo
理解ldap
https://blog.zhaogaz.com/post/2019/ldap-something.html

1. ldap 目录是一个树形结构。
2. 每一个节点entry, 名为DN, DN是可编辑修改的，不变的是EntryUUID
    1. BIND DN （连接director server需要用到的认证用户名，一般还需要密码
    1. Base DN: 含义是搜索的起点DN。配置了之后，就会搜索这个DN以下的节点。
    2. 附加用户DN：这个位置配置的是filter，含义是筛出所有人员的节点
## 属性
每个entry有很多attributes,
1. 普通属性： 如姓名、email
2. 特别属性： object class，这个东西会描述节点的schema 也就是说这个节点中能有什么属性，不能有什么属性，这都是object class说了算的。
3. LDAP还可以保存用户加密过的密码。经常它作为账号服务器，像什么Rancher啊、Jira啊
    1. 表示人员的 Entry 常用inetOrgPerson 、person 这类object class。部门也有部门的object class

openldap 修改某人的密码：

    ldappasswd -H ldap://server_domain_or_IP -x -D "user's_dn" -w old_passwd -a old_passwd -S


## 条目与Directory structure
https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol#History

LDAP目录的条目（entry）由属性（attribute）的一个聚集组成
dn：每一个条目都有一个唯一的标识名（distinguished Name ，DN），如dn：”cn=baby,ou=marketing,ou=people,dc=mydomain,dc=org” 。通过DN的层次型语法结构，可以方便地表示出条目在LDAP树中的位置，通常用于检索。

            dc=org
        |dc=wikipedia
        /          \
    ou=people     ou=groups

dn种类有很多，从目标结构层次上分：
1. rdn：一般指dn逗号最左边的部分，如cn=baby
2. Base DN：LDAP目录树的最顶部就是根，也就是所谓的“Base DN”，如”dc=mydomain,dc=org”. is the DN of the parent entry,

从功能上，可以定义很多DN
1. 部门表 dn
1. 员工表 dn
1. user's dn
3. ....

An entry can look like this when represented in LDAP Data Interchange Format (LDIF) (LDAP itself is a binary protocol):

    dn: cn=John Doe,dc=example,dc=com
    cn: John Doe
    givenName: John
    sn: Doe
    telephoneNumber: +1 888 555 6789
    telephoneNumber: +1 888 555 1232
    mail: john@example.com
    manager: cn=Barbara Doe,dc=example,dc=com
    objectClass: inetOrgPerson
    objectClass: organizationalPerson
    objectClass: person
    objectClass: top

## LDAP 连接协议
LDAP 使用tcp连接

这个协议的核心目的是访问目录的，所以这个协议 有一些操作 Entry 的方法（add delete modify modifyDN） 
还有连接到指定LDAP服务器的方法（bind、unbind）当然了还有几种搜索方式。

比方说如果用Jira配置了LDAP，Jira就会链接LDAP服务器查找特定的人，验证账号密码是否正确。

关于查询我需要再说一下，LDAP查询有一种filter方式，可以通过特定的语法筛出想要的东西。当然了语法是什么不重要。
