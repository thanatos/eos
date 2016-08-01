#![feature(lang_items)]
#![no_std]

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
}

#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "panic_fmt"] extern fn panic_fmt() -> ! {loop{}}
