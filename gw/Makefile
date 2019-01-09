compile:
	cargo build

run:
	./target/debug/rs-server --config /erlang/rust_demo/gw/config.ini -d /erlang/rust_demo/logs -l debug

rel:
	cargo build --release

rrel: run_rel

run_rel:
	./target/release/rs-server --config /erlang/rust_demo/gw/config.ini -d /erlang/rust_demo/logs -l debug

help:
	./target/debug/rs-server -h
