---
title: pgamdin install
date: 2021-11-19
private: true
---
# pgamdin install
以docker 为例

    docker run --rm -it -p 4501:80 -u root -e 'PGADMIN_DEFAULT_EMAIL=ahui@ahui.com' --entrypoint /entrypoint.sh -e 'PGADMIN_DEFAULT_PASSWORD=ahui' dpage/pgadmin4

## ldap 支持
根据 https://www.pgadmin.org/docs/pgadmin4/6.1/ldap.html

    cat <<-MM > config_local.py 
    LDAP_SERVER_URI='ldap://127.0.0.1:389'
    AUTHENTICATION_SOURCES=['ldap']
    LDAP_BIND_USER="CN=my-department,OU=Account,DC=mycompany"
    LDAP_BIND_PASSWORD= "Willpower!"

    # LDAP_BASE_DN
    LDAP_SEARCH_BASE_DN="OU=All Users,DC=mycompany"

    #"search_filter": '(&(objectclass=person)(CN=%s))',
    LDAP_SEARCH_FILTER='(objectclass=person)'
    LDAP_USERNAME_ATTRIBUTE='CN'
    # pgadmin 会搜索全部attributes: sAMAccountName
    MM

    docker run --rm -it -p 4501:80 -v `pwd`/config_local.py:/pgadmin4/config_local.py -u root -e 'PGADMIN_DEFAULT_EMAIL=ahui@ahui.com' --entrypoint /entrypoint.sh -e 'PGADMIN_DEFAULT_PASSWORD=ahui' dpage/pgadmin4