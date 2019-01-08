# PROJECT := release_api
# NODENAME := api
# VERSION := 0.1.0


# all: release test_release
	
# test_release: 
# 	rebar3 compile
# 	rebar3 release
# 	rebar3 tar
# 	mkdir ./$(PROJECT)
# 	tar zxvf ./_build/default/rel/$(NODENAME)/$(NODENAME)-$(VERSION).tar.gz -C ./$(PROJECT)/
# 	cp ./config/config_test.ini ./$(PROJECT)/config.ini
# 	tar czvf  ./bin/$(NODENAME).master.test.tar.gz ./$(PROJECT) 
# 	rm -rf ./$(PROJECT)

# release: 
# 	rebar3 compile
# 	rebar3 release
# 	rebar3 tar
# 	mkdir ./$(PROJECT)
# 	tar zxvf ./_build/default/rel/$(NODENAME)/$(NODENAME)-$(VERSION).tar.gz -C ./$(PROJECT)/
# 	cp ./config/config_release.ini ./$(PROJECT)/config.ini
# 	tar czvf  ./bin/$(NODENAME).master.release.tar.gz ./$(PROJECT) 
# 	rm -rf ./$(PROJECT)

# clean:
# 	rm -rf ./bin/api.master.test.tar.gz
# 	rm -rf ./bin/api.master.release.tar.gz


run:
	cargo build
	./target/debug/mysqlc -c /etc/config.ini -l debug

run1:
	cargo run --bin mysqlc

# gen:
# 	cd protos && /home/maomao/.cargo/bin/pb-rs ./msg.proto

# show:
# 	ps aux | grep gonode

# stop:
# 	killall xgn.node

# # 请先修改app的版本号再执行make up 
# up:
# 	./rebar3 release
# 	./rebar3 appup generate --previous_version $(VERSION)
# 	./rebar3 relup
# 	./rebar3 tar

