
---
title: Ssl Subject Alternative Names (SAN)
date: 2023-03-24
private: true
---
# error SAN
Since Go version 1.15, the deprecated, legacy behavior of treating the CommonName field on X.509 certificates as a hostname when no `Subject Alternative Names (SAN)` are present is now disabled by default. 

    x509: certificate relies on legacy Common Name field, use SANs or temporarily enable Common Name matching with GODEBUG=x509ignoreCN=0


## Resolution:
A new valid certificate needs to be created to include the SAN when creating certificate, by specifying an `-addext` flag. For instance:

    -addext "subjectAltName = DNS:domain-name.com"

    # inspect certificate
    $ openssl x509 -in server.crt -noout -text
    X509v3 Subject Alternative
        Name: DNS:myserver.com


As a workaround, the behavior in which the CommonName field is being treated can be temporarily re-enabled by adding the value `x509ignoreCN=0` to the `GODEBUG` environment variable. 

    echo 'GODEBUG=x509ignoreCN=0' > ~/.profile
