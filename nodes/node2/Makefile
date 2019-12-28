run1:
	./rebar3 shell --name ego1@127.0.0.1 --setcookie node2 

run2:
	./rebar3 shell --name ego2@127.0.0.1 --setcookie node2 


run3:
	./rebar3 shell --name ego3@127.0.0.1 --setcookie node2 


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
