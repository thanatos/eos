ENTRY(start)

SECTIONS {
	. = 1M;

	.boot ALIGN(8) : AT(ADDR(.boot))
	{
		/* ensure that the multiboot header is at the beginning */
		KEEP( *(.multiboot_header) )
	}

	.text :
	{
		*(.text)
	}
}
