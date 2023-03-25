---
title: Create self signed certificate(with CA)
date: 2023-03-25
private: true
---
# Create self signed certificate(with CA)

    # cp /etc/ssl/openssl.cnf
    # cp /System/Library/OpenSSL/openssl.cnf openssl.cnf

## Generate ca.key ca.crt
    openssl genrsa -out ./cakey.pem 1024
    openssl req -new -x509 -key ./cakey.pem -out ./cacert.pem -days 3650 \
    -addext "subjectAltName = DNS:localhost"

如果要给ca 加extensions, 参考:https://www.golinuxcloud.com/add-x509-extensions-to-certificate-openssl/#Step-3_Generate_RootCA_certificate

    cp /System/Library/OpenSSL/openssl.cnf openssl.cnf
    openssl req -new -x509 -days 3650 -config openssl.cnf  -key cakey.pem -out cacert.pem

## Generate nginx.key nginx.csr
注意，要通过`-addext`指定`Subject Alternative  Name(SAN)`, 否则浏览器报`NET::ERR_CERT_COMMON_NAME_INVALID`

    openssl genrsa -out nginx.key 1024
    openssl req -new -key nginx.key -out ./nginx.csr -days 365 \
        -addext "subjectAltName = DNS:local.io"

> mac 自带的/usr/bin/openssl(LibreSSL)不支持`-addext`. 得用brew openssl

## Sign nginx.csr with ca.crt
要指定-CAcreateserial 自动生成 ca.srl 序列号，否则要手动指定`-CAserial 序列号文件`

    openssl x509 -req \
        -in nginx.csr -CA cacert.pem -CAkey cakey.pem -out nginx.crt -days 365 -CAcreateserial 

上面的命令会丢失CSR的extension(SAN)：参考
1. https://security.stackexchange.com/questions/158166/how-to-add-altname-from-csr-file-to-crt-file-using-openssl-x509-req

解决方法是创openssl.custom.cnf

    $ cat openssl.custom.cnf
    [ v3_ca ]
    subjectAltName = DNS:local.io
    subjectKeyIdentifier=hash
    authorityKeyIdentifier=keyid:always,issuer:always
    basicConstraints = CA:true

再签名时使用它

    # openssl help x509
    openssl x509 -req \
        -in nginx.csr -CA cacert.pem -CAkey cakey.pem -out nginx.crt -days 365 -CAcreateserial \
         -extensions v3_ca -extfile openssl.custom.cnf

验证一下证书有没有SAN (也可以在浏览器中查看证书crt的extensions查看)

    openssl x509 -in nginx.crt -noout -text | grep extension -A 5

## Put cacert.pem to Keychain
1. Add cacert.pem to Keychain via `Import Items`
2. Test it with chrome

注意, mac curl 不认keychain 的自定义certs, 可以手动指定cacert

    CURL_CA_BUNDLE=cacert.pem curl 'https://local.io/a.html'
