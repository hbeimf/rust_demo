run:
	./rebar3 shell --name erlango@127.0.0.1 --setcookie erlango_cookie

stop_mac:
	ps -efww|grep go-server|grep -v grep|cut -c 7-15|xargs kill -9

stop:
	ps -efww|grep rs-server|grep -v grep|cut -c 9-15|xargs kill -9
	
# stop1:	
# 	killall rs-server

push:
	git add .
	git commit -m 'pu'
	git push
