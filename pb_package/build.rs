extern crate protobuf_codegen_pure;

// protobuf_codegen_pure::run(
// 	protobuf_codegen_pure::Args {
// 	    out_dir: "src/protos",
// 	    input: &["protos/a.proto", "protos/b.proto"],
// 	    includes: &["protos"],
// 	    customize: protobuf_codegen_pure::Customize {
// 	      ..Default::default()
//     },
// }).expect("protoc");

fn generate_interop() {
    // copy_from_protobuf_test("src/interop/mod.rs");
    // copy_from_protobuf_test("src/interop/json.rs");

    protobuf_codegen_pure::run(protobuf_codegen_pure::Args {
        out_dir: "src/protos",
        includes: &["protos"],
        input: &["protos/msg.proto"],
        customize: Default::default(),
    }).unwrap();
}

fn main() {
    // env_logger::init();

    // cfg_serde();

    // clean_old_files();
    generate_interop();
}