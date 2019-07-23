doc:
https://blog.csdn.net/u011077027/article/details/86225524


3. coturn穿透和转发服务器

sudo apt install coturn 


编译安装coturn

git clone https://github.com/coturn/coturn 
cd coturn 
./configure 
make 
sudo make install

查看是否安装

which turnserver

查看是否安装

which turnserver


配置文件/usr/local/etc/turnserver.conf 或者/etc/turnserver.conf


https://github.com/hbeimf/coturn-docker-image
docker run -d -p 3478:3478 -p 49152-65535:49152-65535/udp instrumentisto/coturn

验证：
https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/


coturn
coturn穿透服务器搭建
https://www.jianshu.com/p/915eab39476d



WebRTC信令服务器的实现

https://blog.csdn.net/tanningzhong/article/details/78547443

5.1 介绍
WebRTC 是一个开源项目，用于Web浏览器之间进行实时音频视频通讯，数据传递。
WebRTC有几个JavaScript APIS。 点击链接去查看demo。

[getUserMedia(): 捕获音频视频]()
[MediaRecorder: 记录音频视频]()
[RTCPeerConnection: 在用户之间传递音频流和视频流]()
[RTCDataChannel: 在用户之间传递文件流]()
5.2 在哪里使用WebRTC?
Chrome
FireFox
Opera
Android
iOS
5.3 什么是信令
WebRTC使用RTCPeerConnection在浏览器之间传递流数据, 但是也需要一种机制去协调收发控制信息，这就是信令。信令的方法和协议并不是在WebRTC中明文规定的。 在codelad中用的是Node，也有许多其他的方法。

5.4 什么是STUN和TURN和ICE?
STUN（Session Traversal Utilities for NAT，NAT会话穿越应用程序）是一种网络协议，它允许位于NAT（或多重NAT）后的客户端找出自己的公网地址，查出自己位于哪种类型的NAT之后以及NAT为某一个本地端口所绑定的Internet端端口。这些信息被用来在两个同时处于NAT路由器之后的主机之间创建UDP通信。该协议由RFC 5389定义。 wikipedia STUN

TURN（全名Traversal Using Relay NAT, NAT中继穿透），是一种资料传输协议（data-transfer protocol）。允许在TCP或UDP的连线上跨越NAT或防火墙。
TURN是一个client-server协议。TURN的NAT穿透方法与STUN类似，都是通过取得应用层中的公有地址达到NAT穿透。但实现TURN client的终端必须在通讯开始前与TURN server进行交互，并要求TURN server产生"relay port"，也就是relayed-transport-address。这时TURN server会建立peer，即远端端点（remote endpoints），开始进行中继（relay）的动作，TURN client利用relay port将资料传送至peer，再由peer转传到另一方的TURN client。wikipedia TURN

ICE （Interactive Connectivity Establishment，互动式连接建立 ），一种综合性的NAT穿越的技术。
互动式连接建立是由IETF的MMUSIC工作组开发出来的一种framework，可整合各种NAT穿透技术，如STUN、TURN（Traversal Using Relay NAT，中继NAT实现的穿透）、RSIP（Realm Specific IP，特定域IP）等。该framework可以让SIP的客户端利用各种NAT穿透方式打穿远程的防火墙。wikipedia ICE




WebRTC被设计用于点对点之间工作，因此用户可以通过最直接的途径连接。然而，WebRTC的构建是为了应付现实中的网络: 客户端应用程序需要穿越NAT网关和防火墙，并且对等网络需要在直接连接失败的情况下进行回调。 作为这个过程的一部分，WebRTC api使用STUN服务器来获取计算机的IP地址，并将服务器作为中继服务器运行，以防止对等通信失败。(现实世界中的WebRTC更详细地解释了这一点。)

5.5 WebRTC是否安全?
WebRTC组件是强制要求加密的，并且它的JavaScript APIS只能在安全的域下使用(HTTPS 或者 localhost)。信令机制并没有被WebRTC标准定义，所以是否使用安全的协议就取决于你自己了。


https://www.cnblogs.com/wainiwann/p/8921108.html

WebRTC多人视频通话架构
https://baijiahao.baidu.com/s?id=1614811416771255019&wfr=spider&for=pc

https://javascript.ruanyifeng.com/htmlapi/webrtc.html

【WebRTC+WebSocket】快速写出自己的直播间
https://www.bilibili.com/video/av52629009/


