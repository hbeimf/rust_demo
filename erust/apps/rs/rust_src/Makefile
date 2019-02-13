RUST_PATH := $(shell pwd)

compile:
	cargo build

run:
	./target/debug/rs-server --config $(RUST_PATH)/config.ini -d $(RUST_PATH)/logs -l debug

rel:
	cargo build --release

rrel: run_rel

run_rel:
	./target/release/rs-server --config $(RUST_PATH)/config.ini -d $(RUST_PATH)/logs -l debug

help:
	./target/debug/rs-server -h
