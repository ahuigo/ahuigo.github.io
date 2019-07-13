---
layout: page
title: py-email
category: blog
description: 
date: 2018-09-28
---
# Python mail
1. yagmail 高效简单的email工具
2. 邮件收发过程

## yagmail
```
import yagmail
yag = yagmail.SMTP(user='test@163.com', password='password', host='smtp.163.com', port=25)
yag = yagmail.SMTP('test@163.com', host='smtp.163.com', port=587, smtp_starttls=True, smtp_ssl=False)
yag = yagmail.SMTP('mygmailusername')
yag.send(['to@someone.com'], 'subject', content, attachments=['a.txt', 'b.jpg'])
contents = ["comtent1", "contents2"]
yag.send(to = to, subject = subject, contents = [body, '<div>...</div>', '/local/to/a.png'])

```

# 邮件收发过程
我们回到电子邮件，假设我们自己的电子邮件地址是`me@163.com`，对方的电子邮件地址是`friend@sina.com`:

1. MUA：Mail User Agent——邮件用户代理。 我们用Outlook或者Foxmail之类
2. MTA: Email从MUA发出去，不是直接到达对方电脑，而是发到MTA：Mail Transfer Agent——邮件传输代理，就是那些Email服务提供商，比如网易、新浪等等。
3. MDA: Email到达新浪的MTA后，由于对方使用的是@sina.com的邮箱，因此，新浪的MTA会把Email投递到邮件的最终目的地MDA：Mail Delivery Agent——邮件投递代理。Email到达MDA后，就静静地躺在新浪的某个服务器上，存放在某个文件或特殊的数据库里，我们将这个长期保存邮件的地方称之为电子邮箱。

4. 同普通邮件类似，Email不会直接到达对方的电脑，因为对方电脑不一定开机，开机也不一定联网。对方要取到邮件，必须通过MUA从MDA上把邮件取到自己的电脑上。

所以，一封电子邮件的旅程就是：

	发件人 -> MUA -> MTA -> MTA -> 若干个MTA -> MDA <- MUA <- 收件人

## 协议
有了上述基本概念，要编写程序来发送和接收邮件，本质上就是：

1. SMTP: 发邮件时，MUA和MTA使用的协议就是SMTP：Simple Mail Transfer Protocol，后面的MTA到另一个MTA也是用SMTP协议。
2. 收邮件时，MUA和MDA使用的协议有两种：
	POP：Post Office Protocol，目前版本是3，俗称POP3；
	IMAP：Internet Message Access Protocol，目前版本是4，优点是不但能取邮件，还可以直接操作MDA上存储的邮件，比如从收件箱移到垃圾箱，等等。

## 认证
邮件客户端软件在发邮件时:
你得填163提供的SMTP服务器地址：smtp.163.com，
为了证明你是163的用户，SMTP服务器还要求你填写邮箱地址和邮箱口令，这样，MUA才能正常地把Email通过SMTP协议发送到MTA。

类似的，从MDA收邮件时:
MDA服务器也要求验证你的邮箱口令，确保不会有人冒充你收取你的邮件

# SMTP发送邮件
Python对SMTP支持有smtplib和email两个模块，`email`负责构造邮件，`smtplib`负责发送邮件。

## 构建邮件
首先，我们来构造一个最简单的纯文本邮件：

	from email.mime.text import MIMEText
	msg = MIMEText('hello, send by Python...', 'plain', 'utf-8')
	msg.as_string() # 'Content-Type: text/plain; charset="utf-8"\nMIME-Version: 1.0\nContent-Transfer-Encoding: base64\n\naGVsbG8sIHNlbmQgYnkgUHl0aG9uLi4u\n'

注意到构造MIMEText对象时，第一个参数就是邮件正文，第二个参数是MIME的subtype，传入'plain'表示纯文本，最终的MIME就是'text/plain'，最后一定要用utf-8编码保证多语言兼容性。

## 发送邮件
然后，通过SMTP发出去：

	# 输入Email地址和口令:
	from_addr = input('From: ')
	password = input('Password: ')
	# 输入收件人地址:
	to_addr = input('To: ')
	# 输入SMTP服务器地址:
	smtp_server = input('SMTP server: ')

	import smtplib
	server = smtplib.SMTP(smtp_server, 25) # SMTP协议默认端口是25
	server.set_debuglevel(1)
	server.login(from_addr, password)
	server.sendmail(from_addr, [to_addr], msg.as_string())
	server.quit()

我们用
1. set_debuglevel(1)就可以打印出和SMTP服务器交互的所有信息。SMTP协议就是简单的文本命令和响应。
2. login()方法用来登录SMTP服务器，
2. sendmail()方法就是发邮件，由于可以一次发给多个人，所以传入一个list，邮件正文是一个str，as_string()把MIMEText对象变成str。

如果想设定timeout(seconds):

    smtplib.SMTP([host[, port[, local_hostname[, timeout]]]])
    # 或者全局
    import socket
    socket.setdefaulttimeout(120)

仔细观察，发现如下问题：

1. 邮件没有主题；
2. 收件人的名字没有显示为友好的名字，比如Mr Green <green@example.com>；
3. 明明收到了邮件，却提示不在收件人中。

这是因为邮件主题、如何显示发件人、收件人等信息并不是通过SMTP协议发给MTA，而是包含在发给MTA的文本中的，所以，我们必须把From、To和Subject添加到MIMEText中，才是一封完整的邮件：

	from email import encoders
	from email.header import Header
	from email.mime.text import MIMEText
	from email.utils import parseaddr, formataddr

	import smtplib

	def _format_addr(s):
		name, addr = parseaddr(s)
		return formataddr((Header(name, 'utf-8').encode(), addr))

	from_addr = input('From: ')
	password = input('Password: ')
	to_addr = input('To: ')
	smtp_server = input('SMTP server: ')

	msg = MIMEText('hello, send by Python...', 'plain', 'utf-8')
	msg['From'] = _format_addr('Python爱好者 <%s>' % from_addr)
	msg['To'] = _format_addr('管理员 <%s>' % to_addr)
	msg['Subject'] = Header('来自SMTP的问候……', 'utf-8').encode()

	server = smtplib.SMTP(smtp_server, 25)
	server.set_debuglevel(1)
	server.login(from_addr, password)
	server.sendmail(from_addr, [to_addr], msg.as_string())
	server.quit()

我们编写了一个函数_format_addr()来格式化一个邮件地址。

1. 注意不能简单地传入`name <addr@example.com>`，因为如果包含中文，需要通过Header对象进行编码。
2. msg['To'] 接收的是字符串而不是list，如果有多个邮件地址，用,分隔即可。

outlook:

    host='smtp.partner.outlook.cn'
    port=587

### 原文
如果我们查看Email的原始内容，可以看到如下经过编码的邮件头：

	From: =?utf-8?b?UHl0aG9u54ix5aW96ICF?= <xxxxxx@163.com>
	To: =?utf-8?b?566h55CG5ZGY?= <xxxxxx@qq.com>
	Subject: =?utf-8?b?5p2l6IeqU01UUOeahOmXruWAmeKApuKApg==?=

这就是经过`Header`对象编码的文本，包含`utf-8`编码信息和`Base64`编码的文本。如果我们自己来手动构造这样的编码文本，显然比较复杂。

## 发送HTML邮件(MIMEText)
如果我们要发送HTML邮件，而不是普通的纯文本文件怎么办？方法很简单，在构造MIMEText对象时，把HTML字符串传进去，再把第二个参数由plain变为html就可以了：

	msg = MIMEText('<html><body><h1>Hello</h1>' +
		'<p>send by <a href="http://www.python.org">Python</a>...</p>' +
		'</body></html>', 'html', 'utf-8')

## 发送附件(MIMEMultipart:MIMEText+MIMEBase)
可以构造一个MIMEMultipart对象代表邮件本身，然后往里面加上一个MIMEText作为邮件正文，再继续往里面加上表示附件的MIMEBase对象即可：

```
# 邮件对象:
msg = MIMEMultipart()
msg['From'] = _format_addr('Python爱好者 <%s>' % from_addr)
msg['To'] = _format_addr('管理员 <%s>' % to_addr)
msg['Subject'] = Header('来自SMTP的问候……', 'utf-8').encode()

# 邮件正文是MIMEText:
msg.attach(MIMEText('send with file...', 'plain', 'utf-8'))

# 添加附件就是加上一个MIMEBase，从本地读取一个图片:
with open('/Users/michael/Downloads/test.png', 'rb') as f:
    # 设置附件的MIME和文件名，这里是png类型:
    mime = MIMEBase('image', 'png', filename='test.png')
    # 加上必要的头信息:
    mime.add_header('Content-Disposition', 'attachment', filename='test.png')
    mime.add_header('Content-ID', '<0>')
    mime.add_header('X-Attachment-Id', '0')
    # 把附件的内容读进来:
    mime.set_payload(f.read())
    # 用Base64编码:
    encoders.encode_base64(mime)
    # 添加到MIMEMultipart:
    msg.attach(mime)
```

然后，按正常发送流程把msg（注意类型已变为MIMEMultipart）发送出去

### 嵌入图片
> 如果要把一个图片嵌入到邮件正文中怎么做？直接在HTML邮件中链接图片地址行不行？答案是，大部分邮件服务商都会自动屏蔽带有外链的图片，因为不知道这些链接是否指向恶意网站。

要把图片嵌入到邮件正文中，我们只需按照发送附件的方式，先把邮件作为附件添加进去，然后，在HTML中通过引用src="cid:0"就可以把附件作为图片嵌入了。如果有多个图片，给它们依次编号，然后引用不同的cid:x即可。

把上面代码加入MIMEMultipart的MIMEText从plain改为html，然后在适当的位置引用图片：

	msg.attach(MIMEText('<html><body><h1>Hello</h1>' +
		'<p><img src="cid:0"></p>' +
		'</body></html>', 'html', 'utf-8'))

再次发送，就可以看到图片直接嵌入到邮件正文的效果：

### 同时支持HTML和Plain格式
如果我们发送HTML邮件，收件人通过浏览器或者Outlook之类的软件是可以正常浏览邮件内容的，但是，如果收件人使用的设备太古老，查看不了HTML邮件怎么办？

办法是在发送HTML的同时再附加一个纯文本，如果收件人无法查看HTML格式的邮件，就可以自动降级查看纯文本邮件。

利用MIMEMultipart就可以组合一个HTML和Plain，要注意指定subtype是alternative：

	msg = MIMEMultipart('alternative')
	msg['From'] = ...
	msg['To'] = ...
	msg['Subject'] = ...

	msg.attach(MIMEText('hello', 'plain', 'utf-8'))
	msg.attach(MIMEText('<html><body><h1>Hello</h1></body></html>', 'html', 'utf-8'))

## 加密SMTP
> 使用标准的25端口连接SMTP服务器时，使用的是明文传输，发送邮件的整个过程可能会被窃听。要更安全地发送邮件，可以加密SMTP会话，实际上就是先创建SSL安全连接，然后再使用SMTP协议发送邮件。

某些邮件服务商，例如Gmail，提供的SMTP服务必须要加密传输。我们来看看如何通过Gmail提供的安全SMTP发送邮件。

必须知道，Gmail的SMTP端口是587，因此，修改代码如下：

	smtp_server = 'smtp.gmail.com'
	smtp_port = 587
	server = smtplib.SMTP(smtp_server, smtp_port)
	server.starttls()
	# 剩下的代码和前面的一模一样:
	server.set_debuglevel(1)
	...

只需要在创建SMTP对象后，立刻调用starttls()方法，就创建了安全连接。后面的代码和前面的发送邮件代码完全一样。

> 如果因为网络问题无法连接Gmail的SMTP服务器，请相信我们的代码是没有问题的，你需要对你的网络设置做必要的调整。

## 小结
构造一个邮件对象就是一个Messag对象，如果构造一个MIMEText对象，就表示一个文本邮件对象，如果构造一个MIMEImage对象，就表示一个作为附件的图片，要把多个对象组合起来，就用MIMEMultipart对象，而MIMEBase可以表示任何对象。它们的继承关系如下：

	Message
	+- MIMEBase
	   +- MIMEMultipart
	   +- MIMENonMultipart
		  +- MIMEMessage
		  +- MIMEText
		  +- MIMEImage

这种嵌套关系就可以构造出任意复杂的邮件。你可以通过email.mime文档查看它们所在的包以及详细的用法。

# POP3收取邮件
> 收取邮件就是编写一个MUA作为客户端，从MDA把邮件获取到用户的电脑或者手机上。收取邮件最常用的协议是POP协议，目前版本号是3，俗称POP3。

Python内置一个poplib模块，实现了POP3协议，可以直接用来收邮件。

收取邮件分两步：

1. 第一步：用poplib把邮件的原始文本下载到本地；
1. 第二部：用email解析原始文本，还原为邮件对象。

## 通过POP3下载邮件
POP3协议本身很简单，以下面的代码为例，我们来获取最新的一封邮件内容：

	import poplib

	# 输入邮件地址, 口令和POP3服务器地址:
	email = input('Email: ')
	password = input('Password: ')
	pop3_server = input('POP3 server: ')

	# 连接到POP3服务器:
	server = poplib.POP3(pop3_server)
	# 可以打开或关闭调试信息:
	server.set_debuglevel(1)
	# 可选:打印POP3服务器的欢迎文字:
	print(server.getwelcome().decode('utf-8'))

	# 身份认证:
	server.user(email)
	server.pass_(password)

	# stat()返回邮件数量和占用空间:
	print('Messages: %s. Size: %s' % server.stat())
	# list()返回所有邮件的编号:
	resp, mails, octets = server.list()
	# 可以查看返回的列表类似[b'1 82923', b'2 2184', ...]
	print(mails)

	# 获取最新一封邮件, 注意索引号从1开始:
	index = len(mails)
	resp, lines, octets = server.retr(index)

	# lines存储了邮件的原始文本的每一行,
	# 可以获得整个邮件的原始文本:
	msg_content = b'\r\n'.join(lines).decode('utf-8')
	# 稍后解析出邮件:
	msg = Parser().parsestr(msg_content)

	# 可以根据邮件索引号直接从服务器删除邮件:
	# server.dele(index)
	# 关闭连接:
	server.quit()

用POP3获取邮件其实很简单，要获取所有邮件，只需要循环使用retr()把每一封邮件内容拿到即可。真正麻烦的是把邮件的原始内容解析为可以阅读的邮件对象。

## 解析邮件
解析邮件的过程和上一节构造邮件正好相反，因此，先导入必要的模块：

	from email.parser import Parser
	from email.header import decode_header
	from email.utils import parseaddr
	import poplib

只需要一行代码就可以把邮件内容解析为Message对象：

	msg = Parser().parsestr(msg_content)

但是这个Message对象本身可能是一个MIMEMultipart对象，即包含嵌套的其他MIMEBase对象，嵌套可能还不止一层。
所以我们要递归地打印出Message对象的层次结构：

	# indent用于缩进显示:
	def print_info(msg, indent=0):
	    if indent == 0:
	        for header in ['From', 'To', 'Subject']:
	            value = msg.get(header, '')
	            if value:
	                if header=='Subject':
	                    value = decode_str(value)
	                else:
	                    hdr, addr = parseaddr(value)
	                    name = decode_str(hdr)
	                    value = u'%s <%s>' % (name, addr)
	            print('%s%s: %s' % ('  ' * indent, header, value))
	    if (msg.is_multipart()):
	        parts = msg.get_payload()
	        for n, part in enumerate(parts):
	            print('%spart %s' % ('  ' * indent, n))
	            print('%s--------------------' % ('  ' * indent))
	            print_info(part, indent + 1)
	    else:
	        content_type = msg.get_content_type()
	        if content_type=='text/plain' or content_type=='text/html':
	            content = msg.get_payload(decode=True)
	            charset = guess_charset(msg)
	            if charset:
	                content = content.decode(charset)
	            print('%sText: %s' % ('  ' * indent, content + '...'))
	        else:
	            print('%sAttachment: %s' % ('  ' * indent, content_type))

邮件的Subject或者Email中包含的名字都是经过编码后的str，要正常显示，就必须decode：

	def decode_str(s):
		value, charset = decode_header(s)[0]
		if charset:
			value = value.decode(charset)
		return value

decode_header()返回一个list，因为像Cc、Bcc这样的字段可能包含多个邮件地址，所以解析出来的会有多个元素。上面的代码我们偷了个懒，只取了第一个元素。

文本邮件的内容也是str，还需要检测编码，否则，非UTF-8编码的邮件都无法正常显示：

	def guess_charset(msg):
		charset = msg.get_charset()
		if charset is None:
			content_type = msg.get('Content-Type', '').lower()
			pos = content_type.find('charset=')
			if pos >= 0:
				charset = content_type[pos + 8:].strip()
		return charset

把上面的代码整理好，我们就可以来试试收取一封邮件。先往自己的邮箱发一封邮件，然后用浏览器登录邮箱，看看邮件收到没，如果收到了，我们就来用Python程序把它收到本地。运行程序，结果如下：

	+OK Welcome to coremail Mail Pop3 Server (163coms[...])
	Messages: 126. Size: 27228317

	From: Test <xxxxxx@qq.com>
	To: Python爱好者 <xxxxxx@163.com>
	Subject: 用POP3收取邮件
	part 0
	--------------------
	  part 0
	  --------------------
		Text: Python可以使用POP3收取邮件……...
	  part 1
	  --------------------
		Text: Python可以<a href="...">使用POP3</a>收取邮件……...
	part 1
	--------------------
	  Attachment: application/octet-stream

我们从打印的结构可以看出，这封邮件是一个MIMEMultipart，它包含两部分：

1. 第一部分又是一个MIMEMultipart，
2. 第二部分是一个附件。而内嵌的MIMEMultipart是一个alternative类型，它包含一个纯文本格式的MIMEText和一个HTML格式的MIMEText。

# demo
[py-smtp.py](/demo/py/smtp.py)