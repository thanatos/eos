mod ffi {
    extern {
        pub fn out_u8(port: u16, value: u8);
    }
}

#[inline]
pub fn out_u8(port: u16, value: u8) {
    unsafe { ffi::out_u8(port, value); }
}
