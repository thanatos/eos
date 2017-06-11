#![feature(lang_items)]
#![no_std]

extern crate rlibc;

#[no_mangle]
pub extern fn rust_main() {

    /* Most of the contents of this function are from
     *   http://os.phil-opp.com/set-up-rust.html
     * This code, because it comes from his blog, carries the license from that
     * blog (MIT or Apache License 2.0)
     * TODO: write some real VGA handling code.
     */

    // ATTENTION: we have a very small stack and no guard page

    let hello = b"Hello World!";
    let color_byte = 0x1f; // white foreground, blue background

    let mut hello_colored = [color_byte; 24];
    for (i, char_byte) in hello.into_iter().enumerate() {
        hello_colored[i*2] = *char_byte;
    }

    // write `Hello World!` to the VGA buffer.
    let buffer_ptr = (0xb8000 + 80 * 2 * 5) as *mut _;
    unsafe { *buffer_ptr = hello_colored };

    vga_text::init();
    vga_text::write_string("This is a test of VGA console writing.\n", 0xa);
    panic!("Reached the end of rust_main()");
}


#[lang = "panic_fmt"]
extern fn panic_fmt(fmt: core::fmt::Arguments, file: &'static str, line: u32) -> ! {
    let mut line_text_data: [u8; 10] = [0; 10];
    let str_len = fmt::u32_to_str(line, &mut line_text_data);
    let line_str = core::str::from_utf8(&line_text_data[..str_len]).unwrap();
    vga_text::write_string("Kernel panic!\n", 0xc);
    vga_text::write_string("  at ", 0x7);
    vga_text::write_string(file, 0x7);
    vga_text::write_string(":", 0x7);
    vga_text::write_string(line_str, 0x7);
    vga_text::write_string("\n", 0x7);
    loop{}
}


mod fmt;
mod io_ports;
mod vga_text;
