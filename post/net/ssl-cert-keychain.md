---
title: ssl keychain
date: 2023-03-28
private: true
---
# ssl keychain
把证书添加到keychain, 两种方法: cli + App

## Add certificate

### via cli

    $ security add-trusted-cert -h
    Usage: add-trusted-cert  [<options>] [certFile]
    -d      
        Add to admin cert store; default is user

e.g.

    # add trust
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./cacert.crt

    # delete trust(del trust only)
    sudo security remove-trusted-cert    -d   ./local.ca.crt
    sudo security remove-trusted-cert -h

    # delete cert(file only)
    [sudo] security delete-certificate -h
    sudo security delete-certificate -c x.com
    sudo security delete-certificate -c local.self
    # delete cert(file+trust)
    sudo security delete-certificate -t -c local.self

    # list keychain 
    sudo security list                            

### via Keychain Access.app
1. Open Keychain Access.app
2. `File->Import Items(Shift+Cmd+i)` to import `my.crt`, `ca.crt` in `system`
3. Search Comman Name and Select *always trust*
![](/img/net/net-ssl-ca/trust-keychain.png)

### Adding the Root Certificate to iOS
following these steps:

1. Email the root certificate to yourself so you can access it on your iOS device
1. Click on the attachment in the email on your iOS device
1. Go to the settings app and click ‘Profile Downloaded’ near the top
1. Click install in the top right
1. Once installed, hit close and go back to the main Settings page
1. Go to “General” > “About”
1. Scroll to the bottom and click on “Certificate Trust Settings”
1. Enable your root certificate under “ENABLE FULL TRUST FOR ROOT CERTIFICATES”
![](/img/net/net-ssl-ca/import-ca-ios.png)