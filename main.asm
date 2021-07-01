[SECTION .data]
dirname: db '.'

[SECTION .bss]
msgbuf:
	resb 512

[SECTION .text]
extern puts
global main

main:

	push rbp
	mov rbp, rsp
	and rsp, 0xfffffffffffffff0

	;open a directory
	mov rax, 2
	mov rdi, dirname
	mov rsi, 0x10000
	syscall

	;getdents(fd, buf, 64)
	mov rdi, rax
	mov rax,78
	mov rsi, msgbuf
	mov rdx, 512
	syscall
	xchg rax,rdx


	;setup registers for loop
	xor rcx, rcx
	xor rbx, rbx

next_dirent:

	mov rax, msgbuf
	add rax, rcx		
	add rax, 0x10

	movzx bx, byte [rax]  		;grab reclen

	push rcx			;Save the register states before the call
	push rdx

	add rax, 0x2
	mov rdi, rax
	call puts

	pop rdx				;Grab the register states
	pop rcx

	add cx, bx			;Add d_reclen to move to next dirent
	cmp cx, dx			;Compare with total dirents
	jl next_dirent

	mov rsp, rbp
	pop rbp
	ret
