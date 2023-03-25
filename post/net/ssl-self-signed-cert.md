---
title: ssl 证书生成
date: 2022-05-26
private: true
---
# cert
根据ssl-ca-key 生成一个私钥

        openssl genrsa -out ./server.key 2048

ca和server 共用一个私key，就可生成 self-signed certificate


## ca crt
基于rsa key后就可以创建ca crt了, 一般是x509标准

    openssl req -new -x509 -key ./server.key -out ./ca.crt -days 3650

## csr　请求证书
可以不带密码,但是common name　要写对

    openssl req -new -key server.key -out server.csr

## 用ca给csr签名
这里ca和server 共用一个key？

    $ openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey server.key -CAcreateserial -out server.crt
    subject=/C=cn/ST=bj/CN=local.com/emailAddress=l@q.com
    -CAkey 选项指明用于签名的密钥
    -CAserial 指明序列号文件
    -CAcreateserial 指明文件不存在时自动生成 ca.srl

## 私钥和证书合并
    cat server.key server.crt > server.pem

# ssl 证书生成
X.509是密码学里公钥证书的格式标准。X.509证书已应用在包括TLS/SSL在内的众多网络协议

## self-signed certificate
### Generating the Certficate Signing Request

    # csr
    openssl req -new -sha256 -key server.key -out server.csr
    # crt
    openssl x509 -req -sha256 -in server.csr -signkey server.key -out server.crt -days 3650

或者直接生成crt

    openssl req -new -x509 -sha256 -key server.key -out server.crt -days 3650
    # or
    openssl x509 -req -new -sha256 -key server.key -out server.crt -days 3650

### 多种非对称算法：RSA，ECDSA,...
Generation of self-sign a certificate with a private (`.key`) and public key (PEM-encodings `.pem`|`.crt`) in one command:

    ```sh
    # ECDSA recommendation key ≥ secp384r1
    # List ECDSA the supported curves (openssl ecparam -list_curves)
    # openssl req -x509 -nodes -newkey ec:secp384r1 -keyout server.ecdsa.key -out server.ecdsa.crt -days 3650
    openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) -keyout server.ecdsa.key -out server.ecdsa.crt -days 3650
    # -pkeyopt ec_paramgen_curve:… / ec:<(openssl ecparam -name …) / -newkey ec:…
    ln -sf server.ecdsa.key server.key
    ln -sf server.ecdsa.crt server.crt
    # RSA recommendation key ≥ 2048-bit
    openssl req -x509 -nodes -newkey rsa:2048 -keyout server.rsa.key -out server.rsa.crt -days 3650
    ln -sf server.rsa.key server.key
    ln -sf server.rsa.crt server.crt
    ```

### 基于config生成
localhost.conf: https://www.humankode.com/ssl/create-a-selfsigned-certificate-for-nginx-in-5-minutes/

    $ cat localhost.conf
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

生成 certificate

    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config localhost.conf

加入系统keychain

    certutil -d sql:$HOME/.pki/nssdb -A -t "P,," -n "localhost" -i localhost.crt

# FAQ
## ECDSA & RSA — FAQ
* Validate the elliptic curve parameters `-check`
* List "ECDSA" the supported curves `openssl ecparam -list_curves`
* Encoding to explicit "ECDSA" `-param_enc explicit`
* Conversion form to compressed "ECDSA" `-conv_form compressed`
* "EC" parameters and a private key `-genkey`

# 使用证书
go-lib/net/http2/tls
1. https://gist.github.com/denji/12b3a568f092ab951456
1. https://blog.bracebin.com/achieving-perfect-ssl-labs-score-with-go
