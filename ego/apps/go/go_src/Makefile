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
