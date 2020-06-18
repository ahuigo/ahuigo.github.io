---
title: ldap
date: 2020-06-18
private: true
---
# ldap
## 条目
dn：每一个条目都有一个唯一的标识名（distinguished Name ，DN），如dn：”cn=baby,ou=marketing,ou=people,dc=mydomain,dc=org” 。通过DN的层次型语法结构，可以方便地表示出条目在LDAP树中的位置，通常用于检索。

rdn：一般指dn逗号最左边的部分，如cn=baby。它与RootDN不同，RootDN通常与RootPW同时出现，特指管理LDAP中信息的最高权限用户。

Base DN：LDAP目录树的最顶部就是根，也就是所谓的“Base DN”，如”dc=mydomain,dc=org”。

## 属性 Attribute
每个条目都可以有很多属性（Attribute），比如常见的人都有姓名、地址、电话等属性。每个属性都有名称及对应的值，属性值可以有单个、多个，比如你有多个邮箱。

属性不是随便定义的，需要符合一定的规则，而这个规则可以通过schema制定。比如，如果一个entry没有包含在 inetorgperson 这个 schema 中的 objectClass: inetOrgPerson ,那么就不能为它指定employeeNumber属性，因为employeeNumber是在inetOrgPerson中定义的。

LDAP为人员组织机构中常见的对象都设计了属性(比如commonName，surname)。下面有一些常用的别名：

属性	语法	描述	值(举例)
cn	Directory String	姓名	sean
sn	Directory String	姓	Chow
ou	Directory String	单位（部门）名称	IT_SECTION
o	Directory String	组织（公司）名称	example
telephoneNumber	Telephone Number	电话号码	110
objectClass	 	内置属性	organizationalPerson