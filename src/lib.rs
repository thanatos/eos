#![feature(lang_items)]
#![no_std]

extern crate rlibc;

#[no_mangle]
pub extern fn rust_main() {
    vga_text::init();
    vga_text::write_string("This is a test of VGA console writing.\n", 0xa);
    panic!("Reached the end of rust_main()");
}


#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    let mut line_text_data: [u8; 10] = [0; 10];
    if let Some(location) = info.location() {
        let str_len = fmt::u32_to_str(location.line(), &mut line_text_data);
        let line_str = core::str::from_utf8(&line_text_data[..str_len]).unwrap();
        vga_text::write_string("Kernel panic!\n", 0xc);
        vga_text::write_string("  at ", 0x7);
        vga_text::write_string(location.file(), 0x7);
        vga_text::write_string(":", 0x7);
        vga_text::write_string(line_str, 0x7);
        vga_text::write_string("\n", 0x7);
    } else {
        vga_text::write_string("Kernel panic!\n", 0xc);
        vga_text::write_string("  at unknown location.", 0x7);
    }
    loop{}
}


mod fmt;
mod io_ports;
mod vga_text;
