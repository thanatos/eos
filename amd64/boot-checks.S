.text
.code32


.global check_multiboot2
check_multiboot2:
	/* This is the multiboot2 magic signature. */
	cmp $0x36d76289, %eax
	jne check_multiboot2_bad_magic
	ret
check_multiboot2_bad_magic:
	mov $not_booted_from_multiboot2, %esi
	call write_error
	hlt


.global check_cpuid
check_cpuid:
	/* As stated in the excellent guide,
	 *   http://os.phil-opp.com/entering-longmode.html
	 * we're going to check if CPUID exists by attempting to flip the CPUID
	 * flag. If we can flip it, we have CPUID!
	 */
	pushfl
	pop %eax

	mov %eax, %edx

	xor $(1 << 21), %eax
	push %eax
	popfl

	pushfl
	pop %eax

	/* Restore flags back to what is was originally. */
	push %edx
	popfl

	/* See if we have CPUID. */
	cmp %eax, %ecx
	je check_cpuid_fail
	ret
check_cpuid_fail:
	mov $no_cpuid, %esi
	call write_error
	hlt


.global check_long_mode
/* check_long_mode() */
check_long_mode:
	push %ebx

	/* Check that the extended CPUID function 0x80000001 is supported. */
	mov $0x80000000, %eax
	cpuid
	cmp $0x80000001, %eax
	jb check_long_mode_fail

	/* Check that the LM bit is set. */
	mov $0x80000001, %eax
	cpuid
	test $(1 << 29), %edx
	jz check_long_mode_fail

	pop %ebx
	ret
check_long_mode_fail:
	mov $no_long_mode, %esi
	call write_error
	hlt


.data
not_booted_from_multiboot2:
.ascii "Eos MUST be booted from a multiboot2 compatible bootloader.\n"
.asciz "Please check that your bootloader is configured to boot Eos as a multiboot2 operating system.\n"
no_cpuid:
.asciz "Eos requires a modern CPU capable of the cpuid instruction.\n"
no_long_mode:
.asciz "Eos requires a 64-bit CPU.\n"
