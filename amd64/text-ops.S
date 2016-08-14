.lcomm base_video_port, 2
.lcomm cursor_x, 1
.lcomm cursor_y, 1

.code32

.global init_text_ops
init_text_ops:
	/* Load the base video port from the BDA (BIOS Data Area) */
	mov (0x0463), %ax
	mov %ax, (base_video_port)

	ret


.global write_error
write_error:
	push %esi
	mov $error_then_colon, %esi
	mov $0x0c, %dl
	call write_message
	pop %esi
	mov $0x07, %dl
	call write_message
	ret

.global write_message
write_message:
	/* esi: pointer to nul terminated string.
	 * dl: color
	 */
	mov $0xb8000, %edi  /* text buffer -> edi */

write_message_loop:
	/* Get the character. */
	mov (%esi), %cl

	/* nul terminator? we're done. */
	cmp $0, %cl
	jz write_message_done

	/* newline? move down a line. */
	cmp $'\n', %cl
	jz write_message_newline

	/* determine output position in memory (eax) */
	push %ecx
	push %edx
	call vga_determine_cursor_position
	pop %edx
	pop %ecx

	/* write the character */
	mov %dl, %ch
	mov %cx, (%edi, %eax, 2)

	/* shift cursor */
	mov (cursor_x), %al
	inc %al
	mov %al, (cursor_x)
	cmp $80, %al
	jz write_message_newline

write_message_loop_end:
	inc %esi
	jmp write_message_loop

write_message_newline:
	movb $0, (cursor_x)
	mov (cursor_y), %al
	cmp $24, %al
	jz write_message_need_scroll
	inc %al
	mov %al, (cursor_y)

	jmp write_message_loop_end

write_message_need_scroll:
	call vga_scroll_display
	jmp write_message_loop_end

write_message_done:
	call vga_update_cursor
	ret


/* vga_determine_cursor_position() -> u16 */
vga_determine_cursor_position:
	xor %eax, %eax
	movzx (cursor_y), %ax
	mov $80, %dx
	mul %dx
	movzx (cursor_x), %dx
	add %dx, %ax  /* position -> ax */
	ret


/* vga_scroll_display() */
vga_scroll_display:
	push %esi
	push %edi
	mov $((80 * 24 * 2) >> 2), %cx
	mov $0xb8000, %edi
	mov $(0xb8000 + (80 * 2)), %esi
vga_scroll_display_loop:
	mov (%esi), %eax
	mov %eax, (%edi)
	add $4, %esi
	add $4, %edi
	dec %cx
	jnz vga_scroll_display_loop
	/* Clear the last line. */
	mov $(0xb8000 + 80 * 24 * 2), %edi
	mov $(80 * 2), %cl
	/* This constant is:
	 * 07 => VGA color code for black BG, grey FG,
	 * 20 => ASCII space
	 * twice, because we write two text cells at a time in the loop.
	 */
	mov $0x07200720, %esi
vga_scroll_display_last_line_loop:
	mov %esi, (%edi)
	add $4, %edi
	dec %cl
	jnz vga_scroll_display_last_line_loop
	pop %edi
	pop %esi
	ret


/* vga_update_cursor() */
vga_update_cursor:
	call vga_determine_cursor_position
	mov %ax, %cx

	mov $0x0f, %al
	mov (base_video_port), %dx
	out %al, %dx
	inc %dx
	mov %cl, %al
	out %al, %dx

	mov $0x0e, %al
	mov (base_video_port), %dx
	out %al, %dx
	inc %dx
	mov %ch, %al
	out %al, %dx
	ret


/* vga_clear_screen() */
.global vga_clear_screen
vga_clear_screen:
	mov $(80 * 25 * 2), %ecx
	/* This constant is:
	 * 07 => VGA color code for black BG, grey FG,
	 * 20 => ASCII space
	 * twice, because we write two text cells at a time in the loop.
	 */
	mov $0x07200720, %eax
	mov $0xb8000, %edx
vga_clear_screen_loop:
	mov %eax, (%edx, %ecx, 4)
	dec %ecx
	jnz vga_clear_screen_loop
	ret


.code64


.global vga_get_early_position
vga_get_early_position:
	xor %rax, %rax
	mov (cursor_x), %al
	mov (cursor_y), %ah
	ret


.data
error_then_colon:
.asciz "Error: "
