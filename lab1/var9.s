bits    64				; res = ((d+b)*(a-c)+(e-b)*(e+b))/(b*b)

section .rodata				; read only data
a:	dw      32000			; тип параметра - word(16 bits)
b:	dw      1			; тип параметра - word(16 bits)
c:	dw      10			; тип параметра - word(16 bits)
d:	dw      32000			; тип параметра - word(16 bits)
e:	dw      32000			; тип параметра - word(16 bits)

section .data
res:	dq	0			; тип параметра - 4*word

section .text				; текст программы
global  _start				; глобальный флаг для началша программы
_start:
        mov	ax, [b]			; передаем в регистр значение b
	or	ax, ax			; проверяем является ли b = 0
	je	b_exit			; если b = 0 меняется флаг и прыгает в метку b_exit
	imul	ax			; тк переменная итак в ax то imul сделает ax * ax 
	shl	edx, 16			; смещаем влево
	mov	ebx, edx		; вносим в ebx, edx
	add	ebx, eax		; теперь в ebx вносим eax b получаем наши преремножение b*b

	movsx	ecx, word[b]		; передаем в ecx b
	movsx	edx, word[d] 		; передаем в edx d
	add	edx, ecx		; складываем в d = d + b
	movsx	eax, word[a]		; передаем в eax a
	movsx	ecx, word[c]		; передаем в ecx с
	sub	eax, ecx		; отнимаем a = a - c
	imul	edx			; edx = edx * eax

	mov	edi, eax		; перемещаем (d+b)*(a-c) в edi
	mov	esi, ebx		; перемещаем b*b в esi
	mov	eax, 0			; обнуляем
	mov	ebx, 0			; обнуляем
	mov	ecx, 0			; и тут обнуляем для дальнейшего использования

	mov	ax, [e]			; заносим в переменную
	imul	ax			; так как переменная итак в ax то imul сделает ax * ax 
	shl	edx, 16			; смещаем влево
	mov	ebx, edx		; вносим в ebx, edx
	add	ebx, eax		; получаем e * e

	sub	ebx, esi		; отнимаем от e * e - b * b
	add	edi, ebx		; складываем e * e + (d+b)(a-c) и получаем всю верхнюю дробь

	mov	ecx, 0			; edi и esi заняты числитель и знаменатель соотвественно
	mov 	ebx, 0			; можно обнулить и xor
	mov	eax, esi		; обнуляем

	idiv	edi
s_exit:
	mov     eax, 60
        mov     edi, 0
        syscall

b_exit:
	mov 	eax, 60
	mov 	edi, 1
	syscall
