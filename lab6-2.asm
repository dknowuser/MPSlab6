$MOD52

;Данная программа обеспечивает ввод аналоговой информации
;по одному из каналов (16 отсчётов) в режиме прерывания АЦП.
;Запуск преобразования выполняется с помощью таймера.
;Информация обрабатывается по алгоритму, представленному в лаб. 1.

ADCCON1 EQU 0EFh
ADCCON2 EQU 0D8h
ADCCON3 EQU 0F5h

ADCDATAL EQU 0D9h
ADCDATAH EQU 0DAh 

;Адреса полученных данных
DATAL EQU 30h
DATAH EQU 31h
COUNTER EQU 32h

ORG 00h
start:
	;Стек растёт вверх - указатель указывает на первый байт после программы
	mov SP, #stack
	
	mov R0, #DATAL
	mov @R0, #00h
	
	mov R0, #DATAH
	mov @R0, #00h
	
	mov R0, #COUNTER
	mov @R0, #00h
	
	;Настройка АЦП
	;Работа в нормальном режиме
	;Запуск преобразования от T/C2
	mov ADCCON1, #42h
	
	;Слушаем только 0-й канал
	mov ADCCON2, #00h
	
	;Разрешение прерывания
	mov IE, #0C0h

	;Перезагружаемое значение
	mov RCAP2L, #00h
	mov RCAP2H, #00h
	
	;Запуск T/C2
	mov T2CON, #04h

;Конец программы
lp:
	jmp lp
	
;Обработчик прерывания АЦП
ORG 33h
	;Складываем младшие биты
	clr C
	mov R0, #DATAL
	mov A, ADCDATAL
	add A, @R0
	mov @R0, A
	
	;Складываем старшие биты с учётом переноса
	mov R0, #DATAH
	mov A, ADCDATAH
	addc A, @R0
	mov @R0, A
	
	;Инкрементируем число отсчётов
	mov R0, #COUNTER
	inc @R0
	
	mov A, @R0
	subb A, #10h
	jnz end_of_handler
	
	;Отключаем T/C2
	mov T2CON, #00h
	
	;Находим ср. арифм. отсчётов
	mov R0, #DATAL; Отбрасываем младшие 4 бита полученной суммы == деление на 16
	mov A, @R0
	anl A, #0F0h
	rr A
	rr A
	rr A
	rr A
	mov @R0, A
	
	;Переносим младшие 4 бита из старшего байта в младший
	mov R1, #DATAH
	mov A, @R1
	anl A, #0Fh
	rl A
	rl A
	rl A
	rl A
	orl A, @R0
	mov @R0, A
	
	;Переносим старшие 4 бита старшего байта в младшую его половину
	mov A, @R1
	anl A, #0F0h
	rr A
	rr A
	rr A
	rr A
	mov @R1, A
	
end_of_handler:
	reti
	
stack:

END