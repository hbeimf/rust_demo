PROJECT := release_control_center
NODENAME := control_center
VERSION := 0.1.0

all: release test_release
	
test_release: 
	rebar3 compile
	rebar3 release
	rebar3 tar
	mkdir ./$(PROJECT)
	tar zxvf ./_build/default/rel/$(NODENAME)/$(NODENAME)-$(VERSION).tar.gz -C ./$(PROJECT)/
	cp ./config/config_test.ini ./$(PROJECT)/config.ini
	tar czvf  ./bin/$(NODENAME).master.test.tar.gz ./$(PROJECT) 
	rm -rf ./$(PROJECT)

release: 
	rebar3 compile
	rebar3 release
	rebar3 tar
	mkdir ./$(PROJECT)
	tar zxvf ./_build/default/rel/$(NODENAME)/$(NODENAME)-$(VERSION).tar.gz -C ./$(PROJECT)/
	cp ./config/config_release.ini ./$(PROJECT)/config.ini
	tar czvf  ./bin/$(NODENAME).master.release.tar.gz ./$(PROJECT) 
	rm -rf ./$(PROJECT)

clean:
	rm -rf ./bin/$(NODENAME).master.test.tar.gz
	rm -rf ./bin/$(NODENAME).master.release.tar.gz

run: 
	rebar3 shell --name $(NODENAME)@127.0.0.1 --setcookie $(NODENAME)_cookie 

