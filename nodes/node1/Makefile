run1:
	./rebar3 shell --name run1@127.0.0.1 --setcookie node1_cookie

run2:
	./rebar3 shell --name run2@127.0.0.1 --setcookie node1_cookie


run3:
	./rebar3 shell --name run3@127.0.0.1 --setcookie node1_cookie


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
