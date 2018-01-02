---
layout: page
title:	Certificate Authority(CA)
category: blog
description: 
---
# Preface
Refer to:
https://workaround.org/certificate-authority

Certificates usually do not come for free. An excellent exception is the first free CA: [CaCert](http://www.cacert.org/).
Currently not all browsers have their certificate built in. Microsoft only seems to trust CAs if they pay an unrealistic amount of money - who's surprised? It is worth spreading the word since this CA is about trust instead of money.

If you do not really care whether the CA is contained in other people's browsers. Then you should consider creating your own CA. 
The only difference is that your clients will get a warning when contacting your server that the CA is not (yet) trusted. This can be either safely ignored or you can make them install your CA's certificate. It is also a good solution if you need a company-wide CA.

# Create Own CA
First you need to to install OpenSSL. On Debian this means running apt-get install openssl. Go to the directory where you want to create the files that make up the CA. Next type(CA is a shell script): 

	/usr/lib/ssl/misc/CA.pl -newca
	/etc/pki/tls/misc/CA -newca

The script will create a new directory named demoCA. 
- The CA's private key (keep it safe!) 
- the public key/certificate (which you may need to give to your clients) will be put there.
The public certificate is the demoCA/cacert.pem file. It does not matter really what you enter into the fields. Just pick a meaningful name for the common name field so that it's clear you are looking at a CA - not a person. So name it "ACME Lasagna Certifiate Authority" instead of "Peters Blaphemic's Fun Certificate". Pick something that sounds official.

> Notice: the CA has an expiry date. The default setting is one year. You may want to edit the file CA.pl and set Days to ten years.

# Create a certificate
Now that you have your own CA you can create certificates for servers. That means you have to do two steps:

Your "client" creates a private key (.key) and a certificate request (.req):

	/usr/lib/ssl/misc/CA.pl -newreq

You sign that request with your CA's key and create a certificate (.crt) that you send to the client:

	/usr/lib/ssl/misc/CA.pl -sign

> Note: If your "client" does not send you a certificate request you can create all the necessary files for them.

To simplify things you may want to use my script makecert that you can use to quickly create new certificates for i.e. Apache SSL servers. Run it like this:

	./makecert mailserver.mydomain.com

You will get three files:

	mailserver.mydomain.com.key (the client's private key)
	mailserver.mydomain.com.req (the client's certificate request)
	mailserver.mydomain.com.crt (the client's signed certificate)

The certificate request is just an intermediate file that is not necessary to run a server using that certificate. You just need the private key and the certificate.

> If you like to use that certificate for an Apache web server you need to put the private key (.key) and the certificate (.crt) into the same file and call it apache.pem.

	cat mailserver.mydomain.com.key mailserver.mydomain.crt > apache.pem

# Sign a request
Some server create a certificate request (SAP, IIS). You will get that request as a file from the client. Use the following command on that request file:

	ca -policy policy_anything -notext -in clients.server.com.req -days 3650 -out clients.server.com.crt

## Some tricks
Show all information about a certificate:

	openssl x509 -noout -text < crt

Calculate the MD5 fingerprint of a certificate:

	openssl x509 -noout -fingerprint < crt

Calculate the SHA1 fingerprint of a certificate:

	openssl x509 -sha1 -noout -fingerprint < crt

The 'makecrt' script

	#
	# Create SSL certificates
	# Christoph Haas <email@christoph-haas.de>
	#
	
	DAYS=3650
	OUTFILE=$1-apache.pem
	
	if [ -z "$1" ]; then
	echo "Usage: $0 [host.domain]"
	exit 10
	fi
	
	echo "Zertifikat für Host $1 wird erzeugt"
	
	(
	echo "My Country"
	echo "My Region"
	echo "My City"
	echo "My Company"
	echo "My Department"
	echo $1
	echo "webmaster@$1"
	echo
	echo
	) |
	openssl req -new -nodes -keyout $1.key -out $1.req -days $DAYS
	openssl ca -policy policy_anything -notext -days $DAYS -out $1.crt -infiles $1.req
	chmod go= $1.crt $1.key $1.req

# Reference
For more details:

- http://datacenteroverlords.com/2012/03/01/creating-your-own-ssl-certificate-authority/

> 根证书(root.pem)本质上是自签名证书，根证书可以用于对其它子证书签名(参考上面的链接)
