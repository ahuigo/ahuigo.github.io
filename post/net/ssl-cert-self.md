---
title: ssl 证书生成
date: 2022-05-26
private: true
---
# ssl selfsigned 证书生成
没有ca的自签名证书，在keychain中会显示`Self-signed root certificate`

## Generating the Certficate Signing Request
先准备好

    openssl genrsa -out nginx.key 1024

再生成csr + crt

    # csr
    openssl req -new -sha256 -key nginx.key -out nginx.csr
    # crt
    openssl x509 -req -sha256 -in nginx.csr -signkey nginx.key -out nginx.crt -days 3650 -extensions v3_ca -extfile openssl.custom.cnf

或者不要csr 直接生成crt

    DOMAIN=local.self
    openssl req -new -x509 -sha256 -key nginx.key -out nginx.crt -days 3650 -addext "subjectAltName = DNS:local.self"
    > Common Name (e.g. server FQDN or YOUR name) []:local.self

    # or
    openssl x509 -req -new -sha256 -key nginx.key -out nginx.crt -days 3650  -extensions v3_ca -extfile openssl.custom.cnf

## 一键生成key +crt
### 多种非对称算法：RSA，ECDSA,...一健生成
Generation of self-sign a certificate with a private (`.key`) and public key (PEM-encodings `.pem`|`.crt`) in one command:

    ```sh
    # ECDSA recommendation key ≥ secp384r1
    # List ECDSA the supported curves (openssl ecparam -list_curves)
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
    -out ./nginx.crt -addext "subjectAltName = DNS:local.self"

### Add cert to keychain
    sudo security add-trusted-cert -d  -k /Library/Keychains/System.keychain nginx.crt

删除：

    sudo security remove-trusted-cert    -d   ./nginx.crt
    sudo security delete-certificate -c local.self

## 基于config生成(未经测试)
openssl.my.conf: https://www.humankode.com/ssl/create-a-selfsigned-certificate-for-nginx-in-5-minutes/

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
