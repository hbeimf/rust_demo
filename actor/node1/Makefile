RUST_PATH := $(shell pwd)
BIN_CMD := rs-node1

compile:
	cargo build

run:
	rm -rf ./logs/*
	./target/debug/$(BIN_CMD) --config $(RUST_PATH)/config.ini -d $(RUST_PATH)/logs -l debug -p $(RUST_PATH)/rs.pid 

rel:
	cargo build --release

rrel: run_rel

run_rel:
	rm -rf ./logs/*
	./target/release/$(BIN_CMD) --config $(RUST_PATH)/config.ini -d $(RUST_PATH)/logs -l debug

help:
	./target/debug/$(BIN_CMD) -h


push:
	git add .
	git commit -m 'push'
	git push