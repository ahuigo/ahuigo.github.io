---
title: ssl keychain
date: 2023-03-28
private: true
---
# ssl keychain

## Add certificate
把证书添加到keychain, 两种方法: cli + App

### add certificate via command line

    $ security add-trusted-cert -h
    Usage: add-trusted-cert  [<options>] [certFile]
    -d      
        Add to admin cert store; default is user

e.g.

    # add trust
    sudo security add-trusted-cert \
    -d -r trustRoot \
    -k /Library/Keychains/System.keychain ./cacert.crt

    # delete trust(del cache only)
    sudo security remove-trusted-cert    -d   ./ca.crt
    sudo security remove-trusted-cert -h

    # delete cert(file only)
    [sudo] security delete-certificate -h
    sudo security delete-certificate -c ca.cert
    sudo security delete-certificate -c local.self

    # list keychain 
    sudo security list                            

### add certificate via Keychain Access.app
1. Open Keychain Access.app
2. `File->Import Items(Shift+Cmd+i)` to import `my.crt`, `ca.crt` in `system` or `login`
3. Select *always trust*
