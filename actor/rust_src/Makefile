RUST_PATH := $(shell pwd)

compile:
	cargo build

run:
	rm -rf ./logs/*
	./target/debug/rs-server --config $(RUST_PATH)/config.ini -d $(RUST_PATH)/logs -l debug -p $(RUST_PATH)/rs.pid 

rel:
	cargo build --release

rrel: run_rel

run_rel:
	rm -rf ./logs/*
	./target/release/rs-server --config $(RUST_PATH)/config.ini -d $(RUST_PATH)/logs -l debug

help:
	./target/debug/rs-server -h


push:
	git add .
	git commit -m 'push'
	git push