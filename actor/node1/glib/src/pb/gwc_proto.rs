use protobuf::*;
use crate::protos;

//pub fn decode_login(pb:Vec<u8>) -> protos::msg::Login {
//    let login_msg : protos::msg::Login = parse_from_bytes::<protos::msg::Login>(&pb).unwrap();
//    login_msg
//}

//pub fn decode_msg(pb:Vec<u8>) -> protos::msg::TestMsg {
//    let test_msg : protos::msg::TestMsg = parse_from_bytes::<protos::msg::TestMsg>(&pb).unwrap();
//    test_msg
//}
//
//pub fn encode_msg() -> Vec<u8> {
//    let mut test_msg = protos::msg::TestMsg::new();
//    test_msg.set_name("tom".to_owned());
//    test_msg.set_nick_name("nick_name".to_owned());
//    test_msg.set_phone("15912341234".to_owned());
//
//    let msg :Vec<u8> = test_msg.write_to_bytes().unwrap();
//    msg
//}
//
//pub fn decode_rpc(pb:Vec<u8>) -> protos::msg::RpcPackage {
//    let rpc_msg : protos::msg::RpcPackage = parse_from_bytes::<protos::msg::RpcPackage>(&pb).unwrap();
//    rpc_msg
//}



//message ReportServerInfo {
////上报服务器信息 http
//string serverType = 1; //服务器类型
//string serverID = 2; //服务器ID  自行分配
//string serverURI = 3; //提供服务的内网地址 ws://192.168.1.1:8000
//string gwcURI = 4; //提供控制节点的内网地址 ws://192.168.1.1:8001
//int32 max = 5; //最大承载用户数
//}

pub fn encode_report_server_info(server_type: String
                               ,server_id: String
                               ,server_uri: String
                               ,gwc_uri: String
                               , max: i32) -> Vec<u8> {
    let mut report_server_info = protos::gwc::ReportServerInfo::new();
    report_server_info.set_serverType(server_type);
    report_server_info.set_serverID(server_id);
    report_server_info.set_serverURI(server_uri);
    report_server_info.set_gwcURI(gwc_uri);
    report_server_info.set_max(max);

    let pb :Vec<u8> = report_server_info.write_to_bytes().unwrap();
    pb
}


