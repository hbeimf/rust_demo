# https://hexdocs.pm/distillery/walkthrough.html#adding-distillery-to-your-project
# https://hexdocs.pm/distillery/getting-started.html

PROJECT_PROD := release_prod_node4
PROJECT_MASTER := release_master_node4
PROJECT_SLAVE := release_slave_node4

NODENAME := node4
VERSION := 0.1.0


all: master slave

run:
	# iex -S mix
	iex --name "$(NODENAME)@127.0.0.1" --cookie "$(NODENAME)_cookie" -S mix

dev:
	mix release --verbose

prod: 
	MIX_ENV=prod mix release --env=prod --verbose
	mkdir $(PROJECT_PROD)
	cp ./config.ini ./$(PROJECT_PROD)/config.ini
	tar zxvf 	_build/prod/rel/$(NODENAME)/releases/$(VERSION)/$(NODENAME).tar.gz -C ./$(PROJECT_PROD)/
	tar czvf  ./tar/$(PROJECT_PROD).tar.gz ./$(PROJECT_PROD) 
	rm -rf ./$(PROJECT_PROD)

master: 
	rm -rf ./tar/*
	MIX_ENV=master mix release --env=master --verbose
	mkdir $(PROJECT_MASTER)
	cp ./config/config_master.ini ./$(PROJECT_MASTER)/config.ini
	tar zxvf 	_build/master/rel/$(NODENAME)/releases/$(VERSION)/$(NODENAME).tar.gz -C ./$(PROJECT_MASTER)/
	tar czvf  ./tar/$(PROJECT_MASTER).tar.gz ./$(PROJECT_MASTER) 
	rm -rf ./$(PROJECT_MASTER)

slave: 
	MIX_ENV=slave mix release --env=slave --verbose
	mkdir $(PROJECT_SLAVE)
	cp ./config/config_slave.ini ./$(PROJECT_SLAVE)/config.ini
	tar zxvf 	_build/slave/rel/$(NODENAME)/releases/$(VERSION)/$(NODENAME).tar.gz -C ./$(PROJECT_SLAVE)/
	tar czvf  ./tar/$(PROJECT_SLAVE).tar.gz ./$(PROJECT_SLAVE) 
	rm -rf ./$(PROJECT_SLAVE)


init: 
	mix deps.get
	mix compile

release_init:
	mix deps.get
	mix compile
	mix release.init


push:
	git add .
	git commit -m 'pu'
	git push