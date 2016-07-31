.text
.code32

.extern start_long_mode


set_up_initial_page_table:
	/* Map the first 2 MiB in L2 */
	xor %eax, %eax
	or $0b10000011 /* writable + present + huge */, %eax
	mov %eax, (page_table_l2)

	/* Map the single L2 table into L3 */
	mov $page_table_l2, %eax
	or $0b11 /* writable + present */, %eax
	mov %eax, (page_table_l3)

	/* Map the single L3 table into L4 */
	mov $page_table_l3, %eax
	or $0b11 /* writable + present */, %eax
	mov %eax, (page_table_l4)

	/* Some final sanity checks: */
	mov $page_table_l2, %eax
	call assert_4kib_aligned
	mov $page_table_l3, %eax
	call assert_4kib_aligned
	mov $page_table_l4, %eax
	call assert_4kib_aligned

	ret


.global enable_long_mode
enable_long_mode:
	call set_up_initial_page_table

	/* CR3 contains the processor's pointer to the L4 page table */
	mov $page_table_l4, %eax
	mov %eax, %cr3

	/* Enable PAE */
	mov %cr4, %eax
	or $(1 << 5), %eax
	mov %eax, %cr4

	/* Enable long mode! */
	mov $0xC0000080 /* "EFER" MSR */, %ecx
	rdmsr
	or $(1 << 8), %eax
	wrmsr

	/* Enable paging */
	mov %cr0, %eax
	or $(1 << 31), %eax
	mov %eax, %cr0

	/* Load the GDT */
	lgdtl gdt64_pointer

	/* Update segment registers: */
	mov $16, %ax
	mov %ax, %ss
	mov %ax, %ds
	mov %ax, %es

	ljmp $8, $start_long_mode

	hlt


assert_4kib_aligned:
	and $(1 * 1024 - 1), %eax
	jnz assert_4kib_aligned_abort
	ret
assert_4kib_aligned_abort:
	mov $page_table_descriptor_not_aligned, %esi
	call write_error
	hlt


.section .rodata

.balign 8
gdt64_table:
	.quad 0  /* null descriptor */
	/* code descriptor */
	.int 0
	.int (1 << 11) | (1 << 12) | (1 << 15) | (1 << 21) | (1 << 9)
		/*
		  1 << 11  code segment
		| 1 << 12  user descriptor
		| 1 << 15  present
		| 1 << 21  long mode
		*/
	/* data descriptor */
	.int 0
	.int (1 << 12) | (1 << 15) | (1 << 9)
		/*
		  0 << 11  code segment
		| 1 << 12  user descriptor
		| 1 << 15  present
		*/

gdt64_pointer:
	.short gdt64_pointer - gdt64_table
	.quad gdt64_table


.section .bss
.balign 4096
.lcomm page_table_l4, 4096
.lcomm page_table_l3, 4096
.lcomm page_table_l2, 4096


.data
page_table_descriptor_not_aligned:
.asciz "Assertion error: Page table pointer not 4 KiB aligned."
