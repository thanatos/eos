.section .multiboot_header, "a"

header_start:

/* Magic Number */
.int 0xe85250d6
/* architecture */
.int 0
/* header length */
.int header_end - header_start
/* checksum */
.set checksum, (~(0xe85250d6 + (header_end - header_start)) + 1) & 0xffffffff
.int checksum

/* end tags */
.short 0  /* type */
.short 0  /* flags */
.int 8  /* size */

header_end:
