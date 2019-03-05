run: stop
	rebar3 shell --name erust@127.0.0.1 --setcookie erust_cookie 

stop:
	ps -efww|grep rs-server|grep -v grep|cut -c 9-15|xargs kill -9
