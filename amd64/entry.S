.text
.code32


.global start
start:
	/* Print a green "OK" ... we're alive. */
	movw $0x2f4f, (0xb8000)
	movw $0x2f4b, (0xb8002)

	/* A very basic stack. */
	mov $(boot_stack + 64), %esp

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

	call enable_long_mode

	mov $everything_ok, %esi
	mov $0x07, %dl
	call write_message

	hlt


.code64


.global start_long_mode
start_long_mode:
	xor %rax, %rax
	movq $(0xb8000 + 80 * 2 + 4), %rax
	movq $0x2f4b2f4f, (%rax)
	hlt


.data
booting_eos:
.asciz "Booting Eos...\n"
everything_ok:
.asciz "Everything was okay.\n"

.lcomm boot_stack, 64
