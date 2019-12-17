run1:
	rebar3 shell --name mydb1@127.0.0.1 --setcookie mydb 

run2:
	rebar3 shell --name mydb2@127.0.0.1 --setcookie mydb


run3:
	rebar3 shell --name mydb3@127.0.0.1 --setcookie mydb 


stop:
	ps -efww|grep xgn.node|grep -v grep|cut -c 9-15|xargs kill -9

push:
	git add .
	git commit -m 'pu'
	git push

ps:
	ps aux | grep xgn.node


