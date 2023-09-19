bits	64
;	compress same symbols to one

section	.data
size	equ	10
namelen	equ 1024
anslen equ 3

msg1:
	db	"Enter string: "
msg1len	equ	$-msg1

str:
	times size	db	0

msg2:
	db "File exists. Rewrite? (Y/N)", 10
msg2len equ $-msg2

newstr:
	times	size	db	0

ans:
	times	anslen	db	0

err2:
	db "No such file or directory", 10

err13:
	db "Permission denied", 10

err17:
	db "File exists!", 10

err21:
	db "Is a directory!", 10

err22:
	db "Invalid arguments", 10

err36:
	db "File name is too long", 10

err255:
	db "Unknown error", 10

errlist:
	times	2	dd err255
	dd err2
	times	10	dd err255
	dd err13
	times	3	dd err255
	dd err17
	times	3	dd err255
	dd err21
	dd err22
	times	13	dd err255
	dd err36
	times	219 dd err255

namefile:
	times	namelen	db 	0

fdw:
	dd -1


section	.text
global	_start
_start:
	cmp dword[rsp], 2
	je m0
	mov ebx, 22
	jmp exit0
m0:
	mov rdi, [rsp+16]
m01:
	mov bx, [rdi+rdx]
	mov [namefile+rdx], bx
	inc edx
	cmp byte[rdi+rdx], 0
	jne m01
	xor edx, edx
	mov eax, 2
	mov edi, namefile
	mov esi, 0c1h
	mov edx, 600o
	syscall
	or eax, eax
	jge work
	cmp eax, -17
	je m1
	mov ebx, eax
	neg ebx
	jmp exit0
m1:
	mov eax, 1
	mov edi, 1
	mov esi, msg2
	mov edx, msg2len
	syscall
	mov eax, 0
	mov edi, 0
	mov esi, ans
	mov edx, anslen
	syscall
	or eax, eax
	jle m2
	cmp eax, ans
	jl m3
m2:
	mov ebx, 17
	jmp exit0
m3:
	cmp byte[ans], 'y'
	je m4
	cmp byte[ans], 'Y'
	je m4
	mov ebx, 17
	jmp exit0
m4:
	mov eax, 2
	mov edi, namefile
	mov esi, 201h
	syscall
	or eax, eax
	jge m5
	mov ebx, eax
	neg ebx
	jmp exit0
m5:
	mov [fdw], eax
	jmp work
exit0:
	or ebx, ebx
	je exit1
	mov eax, 1
	mov edi, 1
	mov esi, [errlist+rbx*4]
	xor edx, edx
perr:
	inc edx
	cmp byte[rsi+rdx-1], 10
	jne perr
	syscall
exit1:
	cmp dword[fdw], -1
	je exit2
	mov eax, 3
	mov edi, [fdw]
	syscall
exit2:
	mov edi, ebx
	mov eax, 60
	syscall
work:
	mov	eax, 1
	mov	edi, 1
	mov	esi, msg1
	mov	edx, msg1len
	syscall
	mov bl, 2
work1:
	xor r8d, r8d
	xor	eax, eax
	xor	edi, edi
	mov	esi, str
	mov	edx, size
	syscall
	or	eax, eax
	jl	n6
	je	n5
	mov esi, str
	mov edi, newstr
	cmp	eax, size
	jl work2
	cmp byte [rsi+rax-1], 10
	je work2
	mov r8d, 1
	jmp work3
work2:
	cmp	byte [rsi+rax-1], 10
	jne	n6
work3:
	xor	ecx, ecx
n0:
	cmp r9d, size
	je n4
	mov al, [rsi]
	inc r9d
	inc esi
	cmp al, 10
	je n3
	cmp al, ' '
	je n1
	cmp al, 9
	je n1
	cmp al, bl
	jne n2
	inc ecx
	jmp n0
n1:
	jecxz	n3
	xor ecx, ecx
	mov byte [rdi], ' '
	mov bl, al
	inc edi
	jmp n0
n2:
	xor ecx, ecx
	inc ecx
	mov bl, al
	mov [rdi], bl
	inc edi
	jmp n0
n3:
	cmp al, 10
	jne n0
	cmp bl, ' '
	jne n4
	dec edi
n4:
	or r8, r8
	jz n41
	mov eax, 1
	mov esi, newstr
	mov edx, edi
	sub edx, newstr
	mov edi, [fdw]
	syscall
	jmp work1
n41:
	mov	byte [rdi], 10
	inc	edi
	mov	eax, 1
	mov	esi, newstr
	mov	edx, edi
	sub	edx, newstr
	mov	edi, [fdw]
	syscall
	jmp	work
n5:
	xor	edi, edi
	mov ebx, 0
	jmp	exit0
n6:
	mov ebx, 255
	jmp exit0
