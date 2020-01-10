c11:
	rm config.ini
	cp ./config.c11.ini ./config.ini
	./rebar3 shell --name c11@127.0.0.1 --setcookie c1_cookie

c12:
	rm config.ini
	cp ./config.c12.ini ./config.ini
	./rebar3 shell --name c12@127.0.0.1 --setcookie c1_cookie


c21:
	rm config.ini
	cp ./config.c21.ini ./config.ini
	./rebar3 shell --name c21@127.0.0.1 --setcookie c2_cookie


c22:
	rm config.ini
	cp ./config.c22.ini ./config.ini
	./rebar3 shell --name c22@127.0.0.1 --setcookie c2_cookie


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
