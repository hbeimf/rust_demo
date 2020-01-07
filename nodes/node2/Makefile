node1:
	rm config.ini
	cp ./config.node1.ini ./config.ini
	./rebar3 shell --name node21@127.0.0.1 --setcookie node2

node2:
	rm config.ini
	cp ./config.node2.ini ./config.ini
	./rebar3 shell --name node22@127.0.0.1 --setcookie node2


node3:
	rm config.ini
	cp ./config.node3.ini ./config.ini
	./rebar3 shell --name node23@127.0.0.1 --setcookie node2


stop:
	ps -efww|grep xgn.node|grep -v grep|cut -c 9-15|xargs kill -9

push:
	git add .
	git commit -m 'pu'
	git push

ps:
	ps aux | grep xgn.node

rel: 
	./rebar3 compile
	./rebar3 release
	./rebar3 tar
