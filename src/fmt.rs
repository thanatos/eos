pub fn u32_to_str(mut n: u32, output: &mut [u8]) -> usize {
    assert!(10 <= output.len());
    if n == 0 {
        output[0] = '0' as u8;
        return 1;
    }

    let mut size: usize = 0;
    while 0 < n {
        let digit = '0' as u8 + (n % 10) as u8;
        output[size] = digit;
        size += 1;
        n /= 10;
    }
    output[0..size].reverse();
    size
}
