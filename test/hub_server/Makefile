PROJECT := release_hub_server
NODENAME := hub_server
VERSION := 0.1.0

all: test release

test:
	rebar3 compile
	rebar3 release
	rebar3 tar
	mkdir $(PROJECT)
	cp ./config/config_test.ini ./$(PROJECT)/config.ini
	tar zxvf ./_build/default/rel/$(NODENAME)/$(NODENAME)-$(VERSION).tar.gz -C ./$(PROJECT)/
	tar czvf  ./bin/$(NODENAME).test.tar.gz ./$(PROJECT) 
	rm -rf ./$(PROJECT)

release:
	rebar3 compile
	rebar3 release
	rebar3 tar
	mkdir $(PROJECT)
	cp ./config/config_release.ini ./$(PROJECT)/config.ini
	tar zxvf ./_build/default/rel/$(NODENAME)/$(NODENAME)-$(VERSION).tar.gz -C ./$(PROJECT)/
	tar czvf  ./bin/$(NODENAME).release.tar.gz ./$(PROJECT) 
	rm -rf ./$(PROJECT)

clean:
	rm -rf ./bin/hub_server.release.tar.gz
	rm -rf ./bin/hub_server.test.tar.gz

run:
	rebar3 shell --name $(NODENAME)@127.0.0.1 --setcookie $(NODENAME)_cookie 

# 请先修改app的版本号再执行make up 
up:
	./rebar3 release
	./rebar3 appup generate --previous_version $(VERSION)
	./rebar3 relup
	./rebar3 tar

