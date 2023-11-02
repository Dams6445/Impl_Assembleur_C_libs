	.file	"test.c"
	.intel_syntax noprefix
	.text
	.section	.rodata
.LC0:
	.string	"Original character: %c\n"
.LC1:
	.string	"Converted character: %c\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 16
	mov	BYTE PTR -1[rbp], 97
	movsx	eax, BYTE PTR -1[rbp]
	mov	edi, eax
	call	toupper@PLT
	mov	BYTE PTR -2[rbp], al
	movsx	eax, BYTE PTR -1[rbp]
	mov	esi, eax
	lea	rax, .LC0[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
	movsx	eax, BYTE PTR -2[rbp]
	mov	esi, eax
	lea	rax, .LC1[rip]
	mov	rdi, rax
	mov	eax, 0
	call	printf@PLT
	mov	eax, 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Debian 13.2.0-4) 13.2.0"
	.section	.note.GNU-stack,"",@progbits
