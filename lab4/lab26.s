bits 64
section .data

; Сообщения и инструменты для работы с интерфейсом
input_msg:
	db "Input x, eps: ", 10, 0
input_f:
	db "%lf %lf", 0
output_f:
	db "f(x) = x / (1 - 2 * x); f(%lf) = %lf", 10, 0
output_file_f:
	db "%d. %lf", 10, 0
clear_f:
	db "%*c", 0
file_f:
	db "w", 0
fdw:
	dd -1
invalid_args:
	db "Wrong amount of arguments", 10
invalid_input:
	db "Invalid input", 10, "Try again", 10, 10, 0
file_err:
	db "Can't open file in write mod", 10, 0
zero:
	dq 0
one:
	dq 1.0
none:
	dq -1.0
two:
	dq 2.0
eps:
	dq 0.0001

section .text

; Включение C-шных функции для вывода, ввода и работы с файлом
extern printf
extern scanf
extern fopen
extern fclose
extern fprintf
extern sqrt

; Присваивание размещений
fw  equ 8
x   equ fw+8
ep1 equ x+8
tl0 equ 8
tl1 equ tl0+8
tl2 equ tl1+8
tl3 equ tl2+8
tl4 equ tl3+8

; xmm0 - input
; Функция C-шная для сравнивания результатов
lib_calc:
	push rbp
	mov rbp, rsp
	sub rsp, x

	mulsd xmm0, [two]
	mulsd xmm0, [none]
	addsd xmm0, [one]
	movsd [rbp-x], xmm15
	push rbp
	mov rbp, rsp
	call sqrt
	leave
	movsd xmm15, [rbp-x]
	movsd xmm1, xmm0
	movsd xmm0, xmm15
	divsd xmm0, xmm1

	mov eax, 2
	mov rdi, output_f
	movsd xmm1, xmm0
	movsd xmm0, xmm15
	call printf

	leave
	ret

; xmm0 - input
; Написанная функция раскладывания в ряд Тейлора функции
tl_calc:
	push rbp
	mov rbp, rsp
	sub rsp, tl4
	xor r8, r8        ; line counter
	inc r8            ; r8 = 1
	movsd xmm3, xmm0
	.while_start:
		mulsd xmm0, xmm15
		addsd xmm1, [one]
		addsd xmm2, [two]
		mulsd xmm0, xmm2
		divsd xmm0, xmm1

		movsd [rbp-tl0], xmm0
		movsd [rbp-tl1], xmm1
		movsd [rbp-tl2], xmm2
		movsd [rbp-tl3], xmm3
		movsd [rbp-tl4], xmm15

		push rbp
		mov rbp, rsp
		sub rsp, x
		mov [rbp-x], r8
		mov rdi, [fdw]
		mov rsi, output_file_f
		mov rax, 2
		mov rdx, r8
		call fprintf
		mov r8, [rbp-x]
		leave

		movsd xmm0, [rbp-tl0]
		movsd xmm1, [rbp-tl1]
		movsd xmm2, [rbp-tl2]
		movsd xmm3, [rbp-tl3]
		movsd xmm15, [rbp-tl4]

		inc r8
		movsd xmm4, xmm3
		addsd xmm3, xmm0
		subsd xmm4, xmm3
		mulsd xmm4, [none]

		ucomisd xmm4, [eps]
		jae .while_start
	.while_end:

	push rbp
	mov rbp, rsp
	mov rax, 2
	mov rdi, output_f
	movsd xmm1, xmm3
	movsd xmm0, xmm15
	call printf
	leave

	leave
	ret

; Начало выполнения программы
global main
main:
	push rbp
	mov rbp, rsp
	sub rsp, x
	cmp rdi, 2
	jne .wrong_args		; Проверяем на неправильные аргументы, аргументов должно быть 2
	mov rdi, [rsi + 8]	; Если все правильно то идем дальше
	mov rsi, file_f
	call fopen		; Открываем переданный файл
	or rax, rax
	jle .wrong_file		; Еще одна проверка
	mov [rbp - fw], rax
	mov [fdw], rax
	.read_x:
		mov edi, input_msg		; Входящее сообщение
		xor eax, eax			; Обнуляем eax
		call printf			; Вызываем C-шную функцию
		mov edi, input_f
		lea rsi, [rbp - x]
		lea rdx, [eps]
		xor eax, eax
		call scanf			; Получаем аргументы
		cmp eax, 2			; Если аргументов 2(как и должно быть), то работаем
		je .start
		cmp eax, 0
		jl .exit0			; Если аргументы не введены, то выход из программы
		mov rdi, invalid_input		; Иначе сообщение об ошибке
		xor rax, rax			; Обнуляем rax
		call printf
		mov rdi, clear_f
		xor rax, rax
		call scanf
		jmp .read_x
		.start:
			movsd xmm0, [rbp - x]
			movsd xmm15, [rbp - x]
			call lib_calc			; Сначала C-шная функция
			movsd xmm0, [rbp - x]		; Используем размещения
			movsd xmm1, [zero]
			movsd xmm2, [none]
			movsd xmm3, [zero]
			movsd xmm15, [rbp - x]
			call tl_calc			; А теперь разложение в ряд
			jmp .exit0
	.wrong_file:
		mov edi, file_err
		xor eax, eax
		call printf
		jmp .exit
	.wrong_args:
		mov edi, invalid_args
		xor eax, eax
		call printf
		jmp .exit
	.exit0:
		mov rdi, [rbp - fw]
		call fclose
	.exit:
		leave
		xor eax, eax
		ret
