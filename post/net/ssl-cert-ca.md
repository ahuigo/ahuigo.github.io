---
title: Create self signed certificate(with CA)
date: 2023-03-25
private: true
---
# Create self signed certificate(with CA)

    # cp /etc/ssl/openssl.cnf
    # cp /System/Library/OpenSSL/openssl.cnf openssl.cnf

## Generate cakey.pem cacert.pem
X.509是密码学里公钥证书的格式标准。X.509证书已应用在包括TLS/SSL在内的众多网络协议

    openssl genrsa -out ./ca.key 1024
    openssl req -new -x509 -key ./ca.key -out ./ca.crt -days 3650 \
    -addext "subjectAltName = DNS:localhost"
    > Common Name (e.g. server FQDN or YOUR name) []:ca.cert 

如果要用配置config, 参考:https://www.golinuxcloud.com/add-x509-extensions-to-certificate-openssl/#Step-3_Generate_RootCA_certificate

    cp /System/Library/OpenSSL/openssl.cnf openssl.cnf
    openssl req -new -x509 -days 3650 -config openssl.cnf  -key ca.key -out ca.crt

## Generate nginx.key nginx.csr
注意，要通过`-addext`指定`Subject Alternative  Name(SAN)`, 否则浏览器报`NET::ERR_CERT_COMMON_NAME_INVALID`

    openssl genrsa -out nginx.key 1024
    openssl req -new -key nginx.key -out ./nginx.csr -days 365 \
        -addext "subjectAltName = DNS:localhost"
    > Common Name (e.g. server FQDN or YOUR name) []:local.ca

> mac 自带的/usr/bin/openssl(LibreSSL)不支持`-addext`. 只能用brew openssl

## Sign nginx.csr with ca.crt
要指定-CAcreateserial 自动生成 ca.srl 序列号，否则要手动指定`-CAserial 序列号文件`

    openssl x509 -req \
        -in nginx.csr -CA ca.crt -CAkey ca.key -out nginx.crt -days 365 -CAcreateserial 

上面的csr转crt时，extension(SAN)会丢失：参考
1. https://security.stackexchange.com/questions/158166/how-to-add-altname-from-csr-file-to-crt-file-using-openssl-x509-req

带上extension的方法是先创建　openssl.custom.cnf

    $ cat openssl.custom.cnf
    # note: DNS:local.ca 要跟csr的域名一样才行！！
    [ v3_ca ]
    subjectAltName = DNS:local.ca
    subjectKeyIdentifier=hash
    authorityKeyIdentifier=keyid:always,issuer:always
    basicConstraints = CA:true

然后签名时使用`-extfile`+`-extensions`指定`v3_ca`

    # openssl help x509
    openssl x509 -req \
        -in nginx.csr -CA ca.crt -CAkey ca.key -out nginx.crt -days 365 -CAcreateserial \
         -extensions v3_ca -extfile openssl.custom.cnf

验证一下证书有没有SAN (也可以在浏览器中查看证书crt的extensions查看)

    openssl x509 -in nginx.crt -noout -text | grep extension -A 5

## Put cacert.pem to Keychain
1. Add `ca.crt` to Keychain.app via `Import Items`
    1. 加入ca.crt后，会显示图标：`Root certificate authority`
    2. 也可加nginx.crt, 会显示：`Intermediate certificate authority`
    3. 没有ca的自签名证书，会显示`Self-signed root certificate`

然后就可以用chrome　访问了
注意, macOSX的 curl 不认keychain 的自定义certs, 可以手动指定ca.crt

    CURL_CA_BUNDLE=ca.crt curl 'https://local.ca/a.html'
