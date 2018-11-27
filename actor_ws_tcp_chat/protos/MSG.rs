
use std::io::Write;
use std::borrow::Cow;
use quick_protobuf::{MessageRead, MessageWrite, BytesReader, Writer, Result};
use quick_protobuf::sizeofs::*;
use super::*;

#[derive(Debug, Default, PartialEq, Clone)]
pub struct TestMsg<'a> {
    pub f1: Option<Cow<'a, str>>,
    pub f2: Option<Cow<'a, str>>,
    pub f3: Option<Cow<'a, str>>,
}

impl<'a> MessageRead<'a> for TestMsg<'a> {
    fn from_reader(r: &mut BytesReader, bytes: &'a [u8]) -> Result<Self> {
        let mut msg = Self::default();
        while !r.is_eof() {
            match r.next_tag(bytes) {
                Ok(10) => msg.f1 = Some(r.read_string(bytes).map(Cow::Borrowed)?),
                Ok(18) => msg.f2 = Some(r.read_string(bytes).map(Cow::Borrowed)?),
                Ok(26) => msg.f3 = Some(r.read_string(bytes).map(Cow::Borrowed)?),
                Ok(t) => { r.read_unknown(bytes, t)?; }
                Err(e) => return Err(e),
            }
        }
        Ok(msg)
    }
}

impl<'a> MessageWrite for TestMsg<'a> {
    fn get_size(&self) -> usize {
        0
        + self.f1.as_ref().map_or(0, |m| 1 + sizeof_len((m).len()))
        + self.f2.as_ref().map_or(0, |m| 1 + sizeof_len((m).len()))
        + self.f3.as_ref().map_or(0, |m| 1 + sizeof_len((m).len()))
    }

    fn write_message<W: Write>(&self, w: &mut Writer<W>) -> Result<()> {
        if let Some(ref s) = self.f1 { w.write_with_tag(10, |w| w.write_string(&**s))?; }
        if let Some(ref s) = self.f2 { w.write_with_tag(18, |w| w.write_string(&**s))?; }
        if let Some(ref s) = self.f3 { w.write_with_tag(26, |w| w.write_string(&**s))?; }
        Ok(())
    }
}

