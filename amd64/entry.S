.text
.code32


.global start
start:
	/* Print a green "OK" ... we're alive. */
	movw $0x2f4f, (0xb8000)
	movw $0x2f4b, (0xb8002)

	/* A very basic stack, from 0x500 to 0x600. */
	mov $0x600, %esp

	/* Push %eax, which *should* contain the multiboot2 magic.
	 * We'll get back to it in a moment.
	 */
	push %eax

	/* Initialize the screen, and say hello properly. */
	call init_text_ops
	call vga_clear_screen

	mov $booting_eos, %esi
	mov $0x07, %dl
	call write_message

	/* Pop %eax; check multiboot2 initialization. */
	pop %eax
	call check_multiboot2
	call check_cpuid
	call check_long_mode

	mov $everything_ok, %esi
	mov $0x07, %dl
	call write_message

	hlt


.data
booting_eos:
.asciz "Booting Eos...\n"
everything_ok:
.asciz "Everything was okay.\n"
