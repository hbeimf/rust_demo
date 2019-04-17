run: stop
	rebar3 shell

stop:
	ps -efww|grep rs-server|grep -v grep|cut -c 9-15|xargs kill -9

push:
	git add .
	git commit -m 'pu'
	git push
