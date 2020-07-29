$MOD52

;Данная программа обеспечивает ввод аналовогой информации
;последовательно по каждому из 8 каналов (по одному отсчёту);
;находит максимальное и минимальное значения. Максимальное
;значение выводится в порты P0 и P1 (P1.0 - P1.3),
;минимальное - в порты P2 и P1 (P1.4 - P1.7).
;Запуск выполняется программно по окончании предыдущего преобразования в режиме слежения

ADCCON1 EQU 0EFh
ADCCON2 EQU 0D8h
ADCCON3 EQU 0F5h

ADCDATAL EQU 0D9h
ADCDATAH EQU 0DAh 

;Минимальное и максимальное считанные значения
MINL EQU 30h
MINH EQU 31h
MAXL EQU 32h
MAXH EQU 33h

;Число каналов
CHANNEL_NUMBER EQU 08h

ORG 00h
start:
	;Настройка АЦП
	;Работа в дежурном режиме
	mov ADCCON1, #80h
	mov ADCCON2, #00h
	
	mov R0, #MINL
	mov @R0, #0FFh
	mov R0, #MINH
	mov @R0, #0FFh
	
	mov R0, #MAXL
	mov @R0, #00h
	mov R0, #MAXH
	mov @R0, #00h
	
	;Счётчик числа каналов
	mov R2, #00h
	
continue:
	;Формируем значение регистра ADCCON2
	mov A, #10h
	orl A, R2
	mov ADCCON2, A
	
	;Ждём завершения преобразования
wait_for_conversion:
	mov A, ADCCON3
	anl A, #080h; Выделяем флаг busy
	clr C
	subb A, #080h; Сброшен ли флаг busy
	jz wait_for_conversion
	
	;Проверяем, является ли полученное значение минимальным
	;Проверяем старший байт
	mov A, ADCDATAH
	anl A, #0Fh
	mov R1, A
	clr C
	mov R0, #MINH
	mov A, @R0
	subb A, R1
	jc check_max; Если старший байт полученного значения больше или равен старшему байту минимального, не продолжаем проверку
	jnz save_min
	
	;Проверяем младший байт
	clr C
	mov R1, ADCDATAL
	mov R0, #MINL
	mov A, @R0
	subb A, R1
	jc check_max; Если младший байт полученного значения больше или равен старшему байту минимального,
	jz check_max; то ничего не делаем

save_min:	
	;Записываем младший байт
	mov A, ADCDATAL
	mov R0, #MINL
	mov @R0, A
	
	;Записываем старший байт
	mov R0, #MINH
	mov A, ADCDATAH
	anl A, #0Fh
	mov @R0, A
	
check_max:
	;Проверяем, является ли полученное значение минимальным
	;Проверяем старший байт
	mov A, ADCDATAH
	anl A, #0Fh
	mov R1, A
	clr C
	mov R0, #MAXH
	mov A, @R0
	subb A, R1
	jc save_max; Если старший байт полученного значения оказался больше старшего байта максимального
	
	;Проверяем младший байт
	clr C
	mov R1, ADCDATAL
	mov R0, #MAXL
	mov A, @R0
	subb A, R1
	jnc prepare_for_next_val; Если младший байт полученного значения оказался меньшим или равным младшему байту максимального
	
save_max:
	;Записываем младший байт
	mov A, ADCDATAL
	mov R0, #MAXL
	mov @R0, A
	
	;Записываем старший байт
	mov R0, #MAXH
	mov A, ADCDATAH
	anl A, #0Fh
	mov @R0, A

prepare_for_next_val:
	inc R2
	clr C
	mov A, R2
	subb A, #08h
	jnz continue
	
;Выводим минимум и максимум в порты
	mov R0, #MINL
	mov A, @R0
	mov P0, A
	
	mov R0, #MINH
	mov A, @R0
	anl A, #0Fh
	mov R1, A
	
	mov R0, #MAXH
	mov A, @R0
	anl A, #0Fh
	mov B, #010h
	mul AB
	orl A, R1
	mov P1, A
	
	mov R0, #MAXL
	mov A, @R0
	mov P2, A
	
;Конец программы
lp:
	jmp lp

END