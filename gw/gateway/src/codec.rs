#![allow(dead_code)]
// use byteorder::{BigEndian, ByteOrder};
use byteorder::{LittleEndian, ByteOrder};
// use bytes::{BufMut, BytesMut};
use bytes::{ BytesMut};
// use serde_json as json;
use std::io;
use tokio_io::codec::{Decoder, Encoder};

/// Client request
#[derive(Serialize, Deserialize, Debug, Message)]
#[serde(tag = "cmd", content = "data")]
pub enum ChatRequest {
    // /// List rooms
    // List,
    // /// Join rooms
    // Join(String),
    // /// Send message
    Message(Vec<u8>),
    // /// Ping
    // Ping,
}

/// Server response
#[derive(Serialize, Deserialize, Debug, Message)]
#[serde(tag = "cmd", content = "data")]
pub enum ChatResponse {
    // Ping,

    // /// List of rooms
    // Rooms(Vec<String>),

    // /// Joined
    // Joined(String),

    /// Message
    Message(Vec<u8>),
}

/// Codec for Client -> Server transport
pub struct ChatCodec;

impl Decoder for ChatCodec {
    type Item = ChatRequest;
    type Error = io::Error;

    // fn decode(&mut self, src: &mut BytesMut) -> Result<Option<Self::Item>, Self::Error> {
    //     let size = {
    //         if src.len() < 2 {
    //             return Ok(None);
    //         }
    //         BigEndian::read_u16(src.as_ref()) as usize
    //     };

    //     if src.len() >= size + 2 {
    //         src.split_to(2);
    //         let buf = src.split_to(size);
    //         Ok(Some(json::from_slice::<ChatRequest>(&buf)?))
    //     } else {
    //         Ok(None)
    //     }
    // }

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

    // fn encode(
    //     &mut self, msg: ChatResponse, dst: &mut BytesMut,
    // ) -> Result<(), Self::Error> {
    //     let msg = json::to_string(&msg).unwrap();
    //     let msg_ref: &[u8] = msg.as_ref();

    //     dst.reserve(msg_ref.len() + 2);
    //     dst.put_u16_be(msg_ref.len() as u16);
    //     dst.put(msg_ref);

    //     Ok(())
    // }

    fn encode(
        &mut self, msg: ChatResponse, dst: &mut BytesMut,
    ) -> Result<(), Self::Error> {
        // let msg_ref: &[u8] = msg.as_ref();
        let ChatResponse::Message(package) = msg;
        debug!("reply: {:?}", package);

        // https://github.com/carllerche/bytes/blob/v0.4.x/src/bytes.rs
        dst.extend_from_slice(package.as_ref());

        Ok(())
    }
}

/// Codec for Server -> Client transport
pub struct ClientChatCodec;

impl Decoder for ClientChatCodec {
    type Item = ChatResponse;
    type Error = io::Error;

    fn decode(&mut self, src: &mut BytesMut) -> Result<Option<Self::Item>, Self::Error> {
        // let size = {
        //     if src.len() < 2 {
        //         return Ok(None);
        //     }
        //     LittleEndian::read_u16(src.as_ref()) as usize
        // };

        // if src.len() >= size + 2 {
        //     src.split_to(2);
        //     let buf = src.split_to(size);
        //     Ok(Some(json::from_slice::<ChatResponse>(&buf)?))
        // } else {
        //     Ok(None)
        // }

        if src.len() < 4 {
            return Ok(None);
        }
        let len = LittleEndian::read_u32(src.as_ref()) as usize;
        debug!("len: {}", len);

        if src.len() >= len {
            let buf = src.split_to(len);
            let v = buf.to_vec();
            debug!("buf: {:?}", v.clone());

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
        // let msg = json::to_string(&msg).unwrap();
        // let msg_ref: &[u8] = msg.as_ref();

        // dst.reserve(msg_ref.len() + 2);
        // dst.put_u16_be(msg_ref.len() as u16);
        // dst.put(msg_ref);

        // Ok(())

        let ChatRequest::Message(package) = msg;
        // debug!("reply: {:?}", package);

        // https://github.com/carllerche/bytes/blob/v0.4.x/src/bytes.rs
        dst.extend_from_slice(package.as_ref());

        Ok(())   
    }
}
