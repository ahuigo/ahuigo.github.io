# IOS Apns(Apple Push Notification Service)
一步一步实现iOS应用PUSH功能
http://tanqisen.github.io/blog/2013/02/27/ios-push-apns/

push的主要工作流程是：

1. iOS设备连接网络后，会自动与APNS保持类似TCP的长链接，等待APNS推送消息的到来；
2. 应用启动时注册消息推送，并获取设备的在APNS中注册的唯一设备标示deviceToken上传给应用服务器(即Provider)；
3. 在需要给应用推送消息时，Provider把push内容、接收push消息的deviceToken按APNS指定的格式打包好，发送给APNS；
4. APNS收到Provider发送的消息后，查找deviceToken指定的设备，如果该设备已经和APNS建立了连接，则立即将消息推送给该设备，如果设备不在线，则在该设备下次连接到APNS后将消息推送到设备。请注意苹果并不保证推送一定成功；
5. 设备收到push消息后，iOS系统会根据SSL证书判断这个push消息是发给那个应用的，进而启动相应客户端。

上述过程中，有两个关键步骤需要自己处理的是：

1. 客户端获取deviceToken，并上传到Provider；
2. Provider发送push消息到APNS。
3. 这两个步骤中都需要苹果的push证书授权，下面就来介绍如何生成push证书，以及Provisioning Profile。
