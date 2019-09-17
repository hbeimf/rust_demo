#![allow(dead_code)]
use byteorder::{LittleEndian, ByteOrder};
use bytes::{ BytesMut};
use std::io;
use tokio_io::codec::{Decoder, Encoder};

#[derive(Serialize, Deserialize, Debug, Message)]
#[serde(tag = "cmd", content = "data")]
pub enum ChatRequest {
    Message(Vec<u8>),
}

#[derive(Serialize, Deserialize, Debug, Message)]
#[serde(tag = "cmd", content = "data")]
pub enum ChatResponse {
    Message(Vec<u8>),
}

pub struct ChatCodec;

impl Decoder for ChatCodec {
    type Item = ChatRequest;
    type Error = io::Error;

    // {len:4, <<cmd:4, pb/binary>>}
    fn decode(&mut self, src: &mut BytesMut) -> Result<Option<Self::Item>, Self::Error> {
        debug!("Peer message");
        if src.len() < 4 {
            return Ok(None);
        }
        let len = LittleEndian::read_u32(src.as_ref()) as usize;
        debug!("len: {}", len);

        if src.len() >= len {
            let buf = src.split_to(len);
            let v = buf.to_vec();
            debug!("buf: {:?}", v.clone());

            Ok(Some(ChatRequest::Message(buf.to_vec())))
        } else {
            Ok(None)
        }
    }
    
}

impl Encoder for ChatCodec {
    type Item = ChatResponse;
    type Error = io::Error;

    fn encode(
        &mut self, msg: ChatResponse, dst: &mut BytesMut,
    ) -> Result<(), Self::Error> {
        let ChatResponse::Message(package) = msg;
        dst.extend_from_slice(package.as_ref());
        Ok(())
    }
}

pub struct ClientChatCodec;

impl Decoder for ClientChatCodec {
    type Item = ChatResponse;
    type Error = io::Error;

    fn decode(&mut self, src: &mut BytesMut) -> Result<Option<Self::Item>, Self::Error> {
        if src.len() < 4 {
            return Ok(None);
        }
        let len = LittleEndian::read_u32(src.as_ref()) as usize;

        if src.len() >= len {
            let buf = src.split_to(len);
            let v = buf.to_vec();

            Ok(Some(ChatResponse::Message(buf.to_vec())))
        } else {
            Ok(None)
        }   
    }
}

impl Encoder for ClientChatCodec {
    type Item = ChatRequest;
    type Error = io::Error;

    fn encode(
        &mut self, msg: ChatRequest, dst: &mut BytesMut,
    ) -> Result<(), Self::Error> {
        let ChatRequest::Message(package) = msg;
        dst.extend_from_slice(package.as_ref());
        Ok(())   
    }
}
