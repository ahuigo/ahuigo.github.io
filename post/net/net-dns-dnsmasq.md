---
title: dns dnsmasq
date: 2021-07-05
private: true
---
# dns dnsmasq
# Never touch your local /etc/hosts file in OS X again
> To setup your computer to work with *.test domains, e.g. project.test, awesome.test and so on, without having to add to your hosts file each time.

## Requirements
* [Homebrew](https://brew.sh/)
* Mountain Lion -> High Sierra

## Install
```
brew install dnsmasq
```

## Setup

### Create config directory
```
mkdir -pv $(brew --prefix)/etc/
```

### Setup *.test

```
echo 'address=/.test/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
```
### Change port for High Sierra
```
echo 'port=53' >> $(brew --prefix)/etc/dnsmasq.conf
```

## Autostart - now and after reboot
```
sudo brew services start dnsmasq
```

## Add to resolvers

### Create resolver directory
```
sudo mkdir -v /etc/resolver
```

### Add your nameserver to resolvers
```
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'
```

## Finished

That's it! You can run scutil --dns to show all of your current resolvers, and you should see that all requests for a domain ending in .test will go to the DNS server at 127.0.0.1

## N.B. never use .dev as a TLD for local dev work. .test is fine though.