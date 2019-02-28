---
title: GPG 的使用
date: 2019-02-27
private:
---
# gpg
GnuPG 主要用来加密文件、邮件的

第一次使用可能什么都没有：

    $ brew install gnupg
    $ gpg --list-key
    gpg: directory '/Users/hilojack/.gnupg' created
    gpg: keybox '~/.gnupg/pubring.kbx' created
    gpg: ~/.gnupg/trustdb.gpg: trustdb created

    $ ls -a ~/.gnupg/
     32B pubring.kbx
    1.2K trustdb.gpg

    600B random_seed
    9.0K gpg.conf
      0B S.gpg-agent
      0B S.gpg-agent.browser
      0B S.gpg-agent.extra
      0B S.gpg-agent.ssh
      0B S.scdaemon

## kill gpg agent

    gpgconf --kill gpg-agent

## generate key

    # gpg --full-generate-key
    $ gpg --gen-key
    passphrase: 私钥密码

    $ tree -a .gnupg/
    S.socket
    ├── S.gpg-agent
    ├── S.gpg-agent.browser
    ├── S.gpg-agent.extra
    ├── S.gpg-agent.ssh
    ├── pubring.kbx 32B
    └── trustdb.gpg 1.3K
    public key
    ├── openpgp-revocs.d
    │   └── B68DA23FDFFF16462DF6C8C68F93E45643C36F0A.rev
    private key
    ├── private-keys-v1.d
    │   ├── 36568FCA3C8FB897C8CAEA2FD404E7C858A9DC43.key
    │   └── A299D9E059073710182D9C40223177148451DADE.key

list key:

    -k, --list-key   list public keyring
    -K, --list-secret list secret keying

### export key
private key:

    gpg --export-secret-keys UID > my-private-key.asc
    gpg --import my-private-key.asc

public key

    gpg --export UID > my-key.asc
    gpg --import my-key.asc

ascii mode

    gpg -a --export UID > my-key.asc.txt
    gpg --import my-key.asc.txt

### delete key:

    --delete-keys           remove keys from the public keyring
    --delete-secret-keys    remove keys from the secret keyring

    # gpg --delete-key UID
    # gpg --delete-secret-keys [用户ID]



## 加密

    -o, --output FILE
    -e, --encrypt FILE with public key
    -d, --decrypt FILE
        --verify      verify a signature

    -r, --recipient USER-ID     encrypt for USER-ID
    -u, --local-user USER-ID    use USER-ID to sign or decrypt

example

    gpg -r ahuigo -e demo.txt 
    gpg -r ahuigo -d demo.txt.gpg > demo.txt

    gpg -r ahuigo -o demo.txt.gpg -e demo.txt
    gpg -r ahuigo -o demo.txt -d demo.txt.gpg

## 签名(不加密)

    gpg -o demo.txt.sig --sign demo.txt
    # clear ascii
    gpg -o demo.txt.asc --clearsign demo.txt

签名与文件分离(验证过了)

    gpg --detach-sign demo.txt
        ...demo.txt.sig

    $ gpg -a --detach-sign demo.txt
    $ gpg  --verify  demo.txt.asc demo.txt


## 加密+签名
有点问题？

    gpg --local-user [发信者ID] --recipient [接收者ID] --armor --sign --encrypt demo.txt
    gpg -r ahuigo -a --sign -e demo.txt

验证

    gpg --verify demo.txt.asc demo.txt

#　参考
- GPG入门教程 https://www.ruanyifeng.com/blog/2013/07/gpg.html
