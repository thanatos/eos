#[repr(C)]
struct ColoredChar {
    character: u8,
    color: u8,
}


#[derive(Copy, Clone)]
struct CursorPosition {
    x: u8,
    y: u8,
}


const TEXT_COLOR_GREY: u8 = 0x7;


static mut cursor_position: CursorPosition = CursorPosition {x: 0, y: 0};


mod ffi {
    extern {
        pub fn vga_get_early_position() -> u16;
    }
}


pub fn init() {
    unsafe {
        let pos = ffi::vga_get_early_position();
        cursor_position.x = (pos & 0xff) as u8;
        cursor_position.y = (pos >> 8) as u8;
    }
}


#[inline]
fn get_video_base_io_port() -> u16 {
    let bda_base_video_port = 0x463 as *mut u16;
    unsafe {
        *bda_base_video_port
    }
}


fn position_to_address(position: CursorPosition) -> *mut ColoredChar {
    let offset = position.x as u16 + position.y as u16 * 80;
    (0xb8000 + offset as u32 * 2) as *mut _
}


fn scroll_if_needed() {
    unsafe {
        if cursor_position.y < 25 {
            return
        }

        ::rlibc::memmove(
            0xb8000 as *mut _,
            (0xb8000 + 80 * 2) as *mut _,
            80 * 24 * 2,
        );
        for x in 0 .. 80 {
            let cell = position_to_address(CursorPosition { x: x, y: 24 });
            *cell = ColoredChar {
                character: b' ',
                color: TEXT_COLOR_GREY,
            };
        }

        cursor_position.y -= 1;
    }
}


pub fn write_string(s: &str, color: u8) {
    for c in s.chars() {
        match c {
            '\n' => {
                unsafe {
                    cursor_position.x = 0;
                    cursor_position.y += 1;
                }
                scroll_if_needed();
            }
            '\x00' ..= '\x7e' => {
                unsafe {
                    let output_location = position_to_address(cursor_position);
                    *output_location = ColoredChar {
                        character: (c as u8),
                        color: color,
                    };
                    cursor_position.x += 1;
                    if 80 <= cursor_position.x {
                        cursor_position.x = 0;
                        cursor_position.y += 1;
                        scroll_if_needed();
                    }
                }
            }
            _ => {
                panic!("Can't output Unicode character \"{}\".", c);
            }
        }
    }
    update_cursor_position(unsafe { cursor_position });
}


fn update_cursor_position(position: CursorPosition) {
    let position = position.x as u16 + position.y as u16 * 80;
    let vga_base_port = get_video_base_io_port();
    crate::io_ports::out_u8(vga_base_port, 0x0f);
    crate::io_ports::out_u8(vga_base_port + 1, (position & 0xff) as u8);
    crate::io_ports::out_u8(vga_base_port, 0x0e);
    crate::io_ports::out_u8(vga_base_port + 1, (position >> 8) as u8);
}
