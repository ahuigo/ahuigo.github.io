# network
## 820.1X 认证配置
很多公司内网会采用这个820.1x配置, 参考 https://help.ubuntu.com/community/Network802.1xAuthentication
1. This authentication protocol can be used on both wireless and wired networks.

### Basic config
ubuntu 内置了 **WPA-Supplicant**:
1. it is used to authenticate 802.1x protocol.
2. it can be used for both **wired** and **wireless** networks as well. 
Wired Network

#### 查看网络接口 
使用ifconfig或ip addr/link 等查看, 我这里使用的是eno1, 一般是用的eth0

    ls /sys/class/net
    ip addr
    ip link
    ifconfig 

show interface status

    ip link show eno1
    ifconfig eno1

#### 配置wpa_supplicant
先创建 wpa conf

    # sudo vim /etc/wpa_supplicant.conf
    # Where is the control interface located? This is the default path:
    ctrl_interface=/var/run/wpa_supplicant

    # Who can use the WPA frontend? Replace "0" with a group name if you
    #   want other users besides root to control it.
    # There should be no need to chance this value for a basic configuration:
    ctrl_interface_group=0

    # IEEE 802.1X works with EAPOL version 2, but the version is defaults 
    #   to 1 because of compatibility problems with a number of wireless
    #   access points. So we explicitly set it to version 2:
    eapol_version=2

    # When configuring WPA-Supplicant for use on a wired network, we don’t need to
    #   scan for wireless access points. See the wpa-supplicant documentation if
    #   you are authenticating through 802.1x on a wireless network:
    # 0 代表不用扫描无线节点
    ap_scan=0

    # 配置820.x
    # 1. PEAP Transport Layer Security(using MSCHAPV2 auth) 
    # 2. no certificates
    network={
        key_mgmt=IEEE8021X
        eap=PEAP
        identity="myusername"
        password="mypassword"
        #phase1="peaplabel=auto tls_disable_tlsv1_2=1"
        phase1="tlsdisable_time_checks=1"
        phase2="auth=MSCHAPV2"
        eapol_flags=0
    }

If EAP-Tunnelled Transport Layer Security, using PAP and MD5 as the authentication protocol. 配置应该是类似：

    network={
        key_mgmt=IEEE8021X
        eap=TTLS MD5
        identity="myloginname"
        anonymous_identity="myloginname"
        password="mypassword"
        phase1="auth=MD5"
        phase2="auth=PAP password=mypassword"
        eapol_flags=0
    }

验证一下是否能认证成功：

    sudo wpa_supplicant -c /etc/wpa_supplicant.conf -D wired -i eno1 -dd

如果失败的话搜索一下谷歌

#### 使用wpa认证
编辑并添加wpa和接口eth0： `sudo vim /etc/network/interfaces`

    # The loopback interface, this is the default configuration:
    auto lo
    iface lo inet loopback

    # The first network interface.
    # In this case we want to receive an IP-address through DHCP:
    auto eth0
    iface eth0 inet dhcp

    # In this case we have a wired network:
    wpa-driver wired

    # Tell the system we want to use WPA-Supplicant with our configuration file:
    wpa-conf /etc/wpa_supplicant.conf

#### 启动网络
    sudo /etc/init.d/networking stop
    sudo /etc/init.d/networking start

    # 或
    #systemctl stop networking.service
    #systemctl start networking.service

如果有错误，检查一下: `systemctl status networking.service`. 
如果遇到 `/usr/sbin/fanctl: No such file or directory`, 这是docker 依赖的东西，如果docker 被删除或更新不正常清理遗留了它，就需要执行清理：

    apt remove --purge ubuntu-fan

### wireless config
参考：https://wiki.archlinux.org/title/wpa_supplicant 有几种连接方式：
1. wpa_cli
2. Connecting with wpa_passphrase

#### Connecting with wpa_cli
vim /etc/wpa_supplicant/wpa_supplicant.conf 创建最小化配置

    ctrl_interface=/run/wpa_supplicant
    update_config=1

Now start wpa_supplicant with:

    wpa_supplicant -B -i interface -c /etc/wpa_supplicant/wpa_supplicant.conf

At this point run wpa_cli: scan ssid

    $ wpa_cli
    > scan
    OK
    <3>CTRL-EVENT-SCAN-RESULTS
    > scan_results
    bssid / frequency / signal level / flags / ssid
    00:00:00:00:00:00 2462 -49 [WPA2-PSK-CCMP][ESS] MYSSID
    11:11:11:11:11:11 2437 -64 [WPA2-PSK-CCMP][ESS] ANOTHERSSID

To associate with MYSSID, add the network, set the credentials and enable it:

    > add_network
    0
    > set_network 0 ssid "MYSSID"
    > set_network 0 psk "passphrase"
    > enable_network 0
    <2>CTRL-EVENT-CONNECTED - Connection to 00:00:00:00:00:00 completed (reauth) [id=0 id_str=]

> If the SSID does not have password authentication, you must explicitly configure the network as keyless by replacing the command `set_network 0 psk "passphrase"` with `set_network 0 key_mgmt NONE`.

Finally save this network in the configuration file and quit wpa_cli:

    > save_config
    OK
    > quit

最后获取ip

    # wpa_supplicant -B -i interface -c /etc/wpa_supplicant/example.conf
    # dhcpcd eth0

#### Connecting with wpa_passphrase

    $ wpa_passphrase MYSSID passphrase
    network={
        ssid="MYSSID"
        #psk="passphrase"
        psk=59e0d07fa4c7741797a4e394f38a5c321e3bed51d54ad5fcbd3f84bc7415d73d
    }
    $ wpa_supplicant -B -i interface -c <(wpa_passphrase MYSSID passphrase)


# open ssh
    sudo apt install openssh-server -y
    sudo systemctl status ssh
    # Ubuntu comes with a firewall configuration tool called UFW. If the firewall is enabled on your system
    sudo ufw allow ssh
