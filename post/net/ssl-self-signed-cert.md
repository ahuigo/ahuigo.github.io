---
title: ssl 证书生成
date: 2022-05-26
private: true
---
# ssl 证书生成
X.509是密码学里公钥证书的格式标准。X.509证书已应用在包括TLS/SSL在内的众多网络协议

有很多种生成方法

## 单独生成key+certificate
Generate private key (.key)

    ```sh
    # Key considerations for algorithm "RSA" ≥ 2048-bit
    openssl genrsa -out server.key 2048
    # Key considerations for algorithm "ECDSA" (X25519 || ≥ secp384r1)
    # https://safecurves.cr.yp.to/
    # List ECDSA the supported curves (openssl ecparam -list_curves)
    openssl ecparam -genkey -name secp384r1 -out server.key
    ```

Generation of self-signed(x509) public key (PEM-encodings `.pem`|`.crt`) based on the private (`.key`)

    ```sh
    openssl req -new -x509 -sha256 -key server.key -out server.crt -days 3650
    ```
    >> Common Name (eg, fully qualified host name) []:s

## self-signed certificate
有很多种对称算法：RSA，ECDSA,...

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

* `.crt` — Alternate synonymous most common among *nix systems `.pem` (pubkey).
* `.csr` — Certficate Signing Requests (synonymous most common among *nix systems).
* `.cer` — Microsoft alternate form of `.crt`, you can use MS to convert `.crt` to `.cer` (`DER` encoded `.cer`, or `base64[PEM]` encoded `.cer`).
* `.pem` = The PEM extension is used for different types of X.509v3 files which contain ASCII (Base64) armored data prefixed with a «—– BEGIN …» line. These files may also bear the `cer` or the `crt` extension.
* `.der` — The DER extension is used for binary DER encoded certificates.

#### Generating the Certficate Signing Request

    openssl req -new -sha256 -key server.key -out server.csr
    openssl x509 -req -sha256 -in server.csr -signkey server.key -out server.crt -days 3650

# FAQ
## ECDSA & RSA — FAQ
* Validate the elliptic curve parameters `-check`
* List "ECDSA" the supported curves `openssl ecparam -list_curves`
* Encoding to explicit "ECDSA" `-param_enc explicit`
* Conversion form to compressed "ECDSA" `-conv_form compressed`
* "EC" parameters and a private key `-genkey`

## CA Bundle Path

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


# 使用证书
go-lib/net/http2/tls
1. https://gist.github.com/denji/12b3a568f092ab951456
1. https://blog.bracebin.com/achieving-perfect-ssl-labs-score-with-go
