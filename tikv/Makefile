run: run1
	
run1:
	rebar3 shell --name tikv1@127.0.0.1 --setcookie tikv 

run2:
	rebar3 shell --name tikv2@127.0.0.1 --setcookie tikv 

run3:
	rebar3 shell --name tikv3@127.0.0.1 --setcookie tikv 

# stop:
# 	ps -efww|grep xgn.node|grep -v grep|cut -c 9-15|xargs kill -9

push:
	git add .
	git commit -m 'pu'
	git push

# ps:
# 	ps aux | grep xgn.node


