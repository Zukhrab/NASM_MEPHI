bits	64				; Выполнить сортировку строк матрицы по значению минимального элемента в них
					; Должны переставляться строки матрицы целиком, а не отдельные элементы
					; 32 бит
					; Гномья сортировка
section	.data
n:	dd	3			; количество строк в массиве

m:	dd	5			; количество столбцов в матрице(размер строки)

matrix:					; сама матрица n*m
	dd	4, 6, 1, 8, 2
	dd	2, 3, 4, 5, 6
	dd	0, -7, 3, -1, -1

result:
	dd	0, 0, 0, 0, 0
	dd	0, 0, 0, 0, 0
	dd	0, 0, 0, 0, 0

min:	dd	0, 0, 0			; массив минимальных элементов в каждой строке

index:	dd	1, 2, 3			; массив указателей на строки


section	.text
global	_start
_start:
	mov	ecx, [n]		; передаем в ecx n = 3, количество строк
	cmp	ecx, 1			; сравнивается ecx и 1, если ecx равен 1, то прыгаем в s_exit
	jle	s_exit			; прыгаем в метку s_exit(success exit)
	mov	ebx, matrix		; передаем в ebx адрес матрицы

m1:
	xor	edi, edi		; обнуляем edi(на всякий случай)
	mov	eax, [ebx]		; передаем первый элемент массива
	push	rcx			; кладем количество строк в стек
	mov	ecx, [m]		; передаем в регистр ecx кол-во элементов в строке
	dec	ecx			; отнимаем единицу у ecx
	cmp	ecx, 0			; сравниваем с нулем
	je	s_exit			; прыгаем в метку m3 если ecx = 0

	xor	esi, esi		; обнуляем
	inc	esi			; делаем esi счетчиком
	xor	edi, edi		; обнуляем
m2:
	cmp 	eax, [rbx + rsi*4]	; сравниваем eax и следующий элемент
	cmovg	eax, [rbx + rsi*4]	; присваивание меньшему
	inc 	esi			; esi++
	loop 	m2


					; тут заполняется массив min
m3:
	mov	[min + edi*4], eax
	inc	edi
	cmp	edi, 3
	jz	m4
	mov	eax, [rbx + rsi*4]
	mov	ecx, 5
	jmp	m2


m4:
	xor	ecx, ecx		; обнуляем для цикла (счетчик)
	xor	edi, edi		; обнуляем просто так
	xor	esi, esi		; счетчик
	xor	ebx, ebx		; обнуляем для передачи адреса min
	xor	eax, eax		; первый элемент массива min

	mov	r11d, index		; передаем адрес массива index, будем оперировать только адресом
	mov	r12d, [index]

	mov	ebx, min		; передаем адрес массива min
	mov	eax, [ebx]		; передаем первый элемент массива min
m5:
	cmp	esi, [n]		; сравниаем наш счетчик esi с [n] = 3
	je	m7			; если esi равен 3 то прыгаем в m7
	cmp	esi, 0			; сравнивается esi с 0
	je	m6			; если esi равен 0 то прыгаем в метку m6
	cmp	[rbx - 4], eax		; сравнивается предыдущий элемент с искомым
	jle	m6			; и если предыдущий меньше или равен искомому то прыгаем на метку m6
	mov	edi, eax		; иначе приcваиваем edi искомый элемент матрицы min
	mov	r13d, r12d
	mov	eax, [rbx - 4]		; нашему регистру eax приваивается предыдущий элемент массива, потому что прыдыдущий больше
	mov	r12d, [r11 - 4]
	mov	[rbx], eax		; теперь приcваиваем нашему искомому элементу в массиве eax(предыдущий)
	mov	[r11d], r12d
	sub	ebx, 4			; уменьшаем адрес на 4 тк размер цифры 4 по усл
	sub	r11d, 4
	dec	esi			; уменьшаем счетчик
	mov	[rbx], edi		; присваиваем нашему прыдыдущего элемента в массиве значение искомого
	mov	[r11d], r13d
	mov	eax, [rbx]		; присваиваем регистру eax прыдыдущий(теперь уже искомый) элемент для сравнения далее
	mov	r12d, [r11d]
	jmp	m5			; прыгаем в m5
m6:
	inc	esi			; увеличиваем наш счетчик на один
	mov	eax, [rbx + 4]		; присваиваем eax значение следующего элемента
	mov	r12d, [r11 + 4]
	add	ebx, 4			; увеличиваем наш адрес на 4
	add	r11d, 4
	jmp	m5			; прыгаем на метку m5
m7:
	xor	eax, eax
	xor	ebx, ebx
	xor	rsi, rsi
	xor 	rdi, rdi
	xor	r11, r11
	xor	r12, r12
	xor	r12, r12
	xor	r13, r13

	mov	eax, result
	mov	ebx, index
	mov	r11d, [ebx]
	mov	esi, matrix
m8:
	mov	ecx, [m]
	inc	edi
	cmp	edi, [n]
	jg	s_exit
	dec	r11d
m9:
	mov	r12, r11
	lea	r12, [r12+r12*4]
	mov	r13d, [rsi + r12*4]
	mov	[eax], r13d
	add	eax, 4
	add	esi, 4
	loop	m9
	mov	r11d, [rbx + rdi*4]
	mov	esi, matrix
	jmp	m8

s_exit:
	mov	eax, 60
	mov	edi, 0
	syscall
b_exit:
	mov	eax, 60
	mov	edi, 1
	syscall

