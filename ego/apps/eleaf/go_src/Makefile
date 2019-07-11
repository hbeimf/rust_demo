GOPATH := $(shell pwd)

all: main

# server: server.go
# 	@GOPATH=$(GOPATH) go get -d
# 	@GOPATH=$(GOPATH) go build -o $@


# GinDemo: GinDemo.go
# 	go get -d
# 	go build -o $@

run:
	go get -d
	go run ./main.go


test:
	cd ./client_test/wsc && rebar3 shell


# cc:
# 	rm -rf ./GinDemo


# https://github.com/getlantern/lantern
start_proxy:
	/usr/bin/lantern &

set_proxy:
	git config --global http.proxy http://127.0.0.1:1080 
	git config --global https.proxy https://127.0.0.1:1080

unset_proxy: 
	git config --global --unset http.proxy 
	git config --global --unset https.proxy

show_proxy:
	git config http.proxy
