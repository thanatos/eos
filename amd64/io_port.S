.global out_u8
out_u8:
	mov %rdi, %rdx
	mov %rsi, %rax
	out %al, %dx
	ret
