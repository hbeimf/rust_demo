compile:
	cargo build
	./target/debug/rs-server --config /erlang/rust_demo/gw/config.ini -l debug

run:
	./target/debug/rs-server --config /erlang/rust_demo/gw/config.ini -l debug

rel:
	cargo build --release

rrel: run_rel

run_rel:
	./target/release/rs-server --config /erlang/rust_demo/gw/config.ini -l debug

help:
	./target/debug/rs-server -h
