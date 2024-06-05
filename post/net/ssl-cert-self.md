---
title: ssl 证书生成
date: 2022-05-26
private: true
---
# ssl selfsigned 证书生成
没有ca的自签名证书，在keychain中System会显示`Self-signed root certificate`

## Generating the Certficate Signing Request
先准备好key

    openssl genrsa -out nginx.key 1024

再生成csr + crt (openssl.custom.cnf 文件参考: ssl-cert-ca.md)

    # csr
    openssl req -new -sha256 -key nginx.key -out nginx.csr
    # 自己给自己签发crt
    openssl x509 -req -sha256 -in nginx.csr -signkey nginx.key -out nginx.crt -days 3650 -extensions v3_ca -extfile openssl.custom.cnf

或者不要csr 直接生成crt(ca证书就是这样的: req -new -x509)

    DOMAIN=local.self2
    openssl req -new -x509 -sha256 -key nginx.key -out nginx.crt -days 3650 -subj "/C=CN/ST=Some-Province/O=Internet Widgets, Inc./CN=$DOMAIN" -addext "subjectAltName = DNS:$DOMAIN"

    # or with x.cnf
    openssl x509 -req -new -sha256 -key nginx.key -out nginx.crt -days 3650  -extensions v3_ca -extfile openssl.custom.cnf

或一键生成key+crt: req -x509 -nodes -newkey

    DOMAIN=local.self2
    openssl req -x509 -nodes -newkey rsa:1024    -keyout nginx.key -out nginx.crt -days 3650 -subj "/C=CN/ST=Some-Province/O=Internet Widgets, Inc./CN=$DOMAIN" -addext "subjectAltName = DNS:$DOMAIN"

## 一键生成key +crt
### 多种非对称算法：RSA，ECDSA,...一健生成
Generation of self-sign a certificate with a private (`.key`) and public key (PEM-encodings `.pem`|`.crt`) in one command:

    ```sh
    # ECDSA recommendation key ≥ secp384r1
    # openssl ecparam -list_curves: List ECDSA the supported curves 
    # openssl req -x509 -nodes -newkey ec:secp384r1 -keyout server.ecdsa.key -out server.ecdsa.crt -days 3650
    openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) -keyout server.ecdsa.key -out server.ecdsa.crt -days 3650

    # -pkeyopt ec_paramgen_curve:… / ec:<(openssl ecparam -name …) / -newkey ec:…
    ln -sf server.ecdsa.key nginx.key
    ln -sf server.ecdsa.crt nginx.crt

    # RSA recommendation key ≥ 2048-bit
    openssl req -x509 -nodes -newkey rsa:2048 -keyout server.rsa.key -out server.rsa.crt -days 3650
    ln -sf server.rsa.key nginx.key
    ln -sf server.rsa.crt nginx.crt
    ```

### 一键生成rsa key + crt

    # note：也可以　-config ./openssl.cnf 
    domain=local.self
    openssl req \
    -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/CN=$domain" \
    -keyout ./nginx.key \
    -out ./nginx.crt -addext "subjectAltName = DNS:$domain"

### Add cert to keychain
> refer: ssl-cert-keychin.md

## 基于config生成(未经测试)
openssl.my.conf: https://www.humankode.com/ssl/create-a-selfsigned-certificate-for-nginx-in-5-minutes/

### 准备 openssl.cnf
    # cp /etc/ssl/openssl.cnf (旧)
    # cp /System/Library/OpenSSL/openssl.cnf openssl.cnf
    $ cat openssl.my.conf
    [req]
    default_bits       = 2048
    default_keyfile    = localhost.key
    distinguished_name = req_distinguished_name
    req_extensions     = req_ext
    x509_extensions    = v3_ca

    [req_distinguished_name]
    countryName                 = Country Name (2 letter code)
    countryName_default         = US
    stateOrProvinceName         = State or Province Name (full name)
    stateOrProvinceName_default = New York
    localityName                = Locality Name (eg, city)
    localityName_default        = Rochester
    organizationName            = Organization Name (eg, company)
    organizationName_default    = localhost
    organizationalUnitName      = organizationalunit
    organizationalUnitName_default = Development
    commonName                  = Common Name (e.g. server FQDN or YOUR name)
    commonName_default          = localhost
    commonName_max              = 64

    [req_ext]
    subjectAltName = @alt_names

    [v3_ca]
    subjectAltName = @alt_names

    [alt_names]
    DNS.1   = localhost
    DNS.2   = 127.0.0.1

生成 key + certificate 

    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config openssl.my.conf
