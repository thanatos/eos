.global start

.text
.code32
start:
	movw $0x2f4f, (0xb8000)
	movw $0x2f4b, (0xb8002)
	hlt
