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

