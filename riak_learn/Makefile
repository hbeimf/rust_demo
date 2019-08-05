run: 
	rebar3 shell --name riak_learn@127.0.0.1 --setcookie riak_learn 

stop:
	ps -efww|grep xgn.node|grep -v grep|cut -c 9-15|xargs kill -9

push:
	git add .
	git commit -m 'pu'
	git push

ps:
	ps aux | grep xgn.node

release:
	rebar3 release 


# && _build/default/rel/rc_example/bin/rc_example


console:
	rebar3 release && _build/default/rel/riak_learn/bin/riak_learn console
