run:
	rebar3 shell --name php_demo@127.0.0.1 --setcookie php_demo

stop:
	ps -efww|grep xgn.node|grep -v grep|cut -c 9-15|xargs kill -9

push:
	git add .
	git commit -m 'pu'
	git push

ps:
	ps aux | grep xgn.node


test:
	rebar3 ct
