---
title: Create self signed certificate(with CA)
date: 2023-03-25
private: true
---
# demo
- https://github.com/ahuigo/2wayssl
- https://github.com/ahuigo/selfhttps

# Create ca signed certificate

    # cp /etc/ssl/openssl.cnf
    # cp /System/Library/OpenSSL/openssl.cnf openssl.cnf

## Generate cakey.pem cacert.pem
X.509是密码学里公钥证书的格式标准。X.509证书已应用在包括TLS/SSL在内的众多网络协议

    openssl genrsa -out ./ca.key 4096
    openssl req -new -x509 -key ./ca.key -out ./ca.crt -days 3650 
    -addext "subjectAltName = DNS:localhost"
    > Common Name (e.g. server FQDN or YOUR name) []:localhost

-nodes 不对私钥加密，-sha256 指定签名算法

    openssl req -new -x509 -key ./ca.key -out ./ca.pem -days 1825  -nodes -sha256 

如果要用配置config, 参考:https://www.golinuxcloud.com/add-x509-extensions-to-certificate-openssl/#Step-3_Generate_RootCA_certificate

    cp /System/Library/OpenSSL/openssl.cnf openssl.cnf
    openssl req -new -x509 -days 3650 -config openssl.cnf  -key ca.key -out ca.crt

## Generate nginx.key nginx.csr
注意，要通过`-addext`指定`Subject Alternative  Name(SAN)`, 否则浏览器报`NET::ERR_CERT_COMMON_NAME_INVALID`

    openssl genrsa -out nginx.key 4096
    openssl req -new -key nginx.key -out ./nginx.csr -days 365 \
        -addext "subjectAltName = DNS:localhost"
    > Common Name (e.g. server FQDN or YOUR name) []:local.ca

> mac 自带的/usr/bin/openssl(LibreSSL)不支持`-addext`. 只能用brew openssl

## Sign nginx.csr with ca.crt
要指定-CAcreateserial 自动生成 `ca.srl` 序列号文件，否则要手动指定`-CAserial 序列号文件` 

    # 还要加　-Extension SAN
    openssl x509 -req -CA ca.crt -CAkey ca.key -days 365 -CAcreateserial -in nginx.csr -out nginx.crt -extensions SAN -extfile <(printf "\n[SAN]\nsubjectAltName=DNS:my.local")

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

    $ 或者
    [ v3_ca ]
    subjectAltName = $ENV::ALTNAME
    basicConstraints = CA:FALSE
    keyUsage = nonRepudiation, digitalSignature, keyEncipherment

然后签名时使用`-extfile`+`-extensions`指定`v3_ca`

    # openssl help x509
    openssl x509 -req \
        -in nginx.csr -CA ca.crt -CAkey ca.key -out nginx.crt -days 365 -CAcreateserial \
         -extensions v3_ca -extfile openssl.custom.cnf

或者只指定使用`-extfile`(如果文件内容全部是v3_ca):

    $ cat v3_ca.cnf
    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    subjectAltName = @alt_names
    [alt_names]
    DNS.1 = dev.local.com
    DNS.2 = dev2.local.com
    IP.1 = 127.0.0.1

    $ openssl x509 -req \
        -in nginx.csr -CA ca.crt -CAkey ca.key -out nginx.crt -days 365 -CAcreateserial \
        -extfile ./v3_ca.cnf

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


# CA Bundle Path(system)

| Distro                                                       	| Package         	| Path to CA                               	|
|--------------------------------------------------------------	|-----------------	|------------------------------------------	|
| Fedora, RHEL, CentOS                                         	| ca-certificates 	| /etc/pki/tls/certs/ca-bundle.crt         	|
| Debian, Ubuntu, Gentoo, Arch Linux                           	| ca-certificates 	| /etc/ssl/certs/ca-certificates.crt       	|
| SUSE, openSUSE                                               	| ca-certificates 	| /etc/ssl/ca-bundle.pem                   	|
| FreeBSD                                                      	| ca_root_nss     	| /usr/local/share/certs/ca-root-nss.crt   	|
| Cygwin                                                       	| -               	| /usr/ssl/certs/ca-bundle.crt             	|
| macOS (MacPorts)                                             	| curl-ca-bundle  	| /opt/local/share/curl/curl-ca-bundle.crt 	|
| Default cURL CA bunde path (without --with-ca-bundle option) 	|                 	| /usr/local/share/curl/curl-ca-bundle.crt 	|
| Really old RedHat?                                           	|                 	| /usr/share/ssl/certs/ca-bundle.crt       	|
