GOPATH := $(shell pwd)

all: gonode

test: Test

Test:
	@GOPATH=$(GOPATH) go get -d
	@GOPATH=$(GOPATH) go test -v ./model/Redis_test.go ./model/Redis.go
	@GOPATH=$(GOPATH) go test -v ./model/Mysql_test.go ./model/Mysql.go

gonode:
	@GOPATH=$(GOPATH) go get -d
	@GOPATH=$(GOPATH) go build -o $@

clean:
	@GOPATH=$(GOPATH) go clean
	@${RM} -r pkg/ src/

.PHONY: gonode

dep:
	go get github.com/golang/net
	go get github.com/golang/sys


run:
	go get -d
	go run ./gonode.go


# http://www.fecshop.com/topic/806
# cd ~/go/src
# mkdir -p golang.org/x
# cd golang.org/x
# git clone https://github.com/golang/sys.git