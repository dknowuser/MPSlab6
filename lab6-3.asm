$MOD52

;Данная программа обеспечивает ввод аналоговой информации по одному из каналов (32 отсчёта)
;и запись результата преобразования во внешнюю память данных в режиме прямого доступа.

ADCCON1 EQU 0EFh
ADCCON2 EQU 0D8h
ADCCON3 EQU 0F5h

ADCDATAL EQU 0D9h
ADCDATAH EQU 0DAh 

DMAL EQU 0D2h
DMAH EQU 0D3h
DMAP EQU 0D4h

COUNTER EQU 30h

ORG 00h
start:
	;Разметка внешней статической памяти
	mov DPL, #00h
	mov DPH, #00h
	
	mov A, #00h
	movx @DPTR, A
	
	inc DPL
	movx @DPTR, A
	
	inc DPL
	mov A, #0F0h ; Конец таблицы
	movx @DPTR, A
	
	inc DPL
	mov A, #00h
	movx @DPTR, A
	
	mov R0, #COUNTER
	mov @R0, #00h
	
	;Разрешаем прерывания АЦП
	mov IE, #0C0h
	
	;Настройка АЦП
	;Работа в нормальном режиме
	mov ADCCON1, #40h
	
	;Разрешение режима ПДП
	;Читаем канал 0
	mov ADCCON2, #60h
	
	;Конец программы
lp:
	;mov A, ADCCON3
	;anl A, #80h
	;clr C
	;subb A, #80h; Ждём, пока сбросится флаг busy
	;jz lp
	
	;mov ADCCON2, #60h
	jmp lp
	
;Обработчик прерывания АЦП
ORG 33h
	mov ADCCON2, #00h
	inc @R0
	mov A, @R0
	clr C
	subb A, #20h
	jz end_of_handler

	mov DMAL, #00h; Переинициализируем DMAPHL для приёма следующего значения
	mov DMAH, #00h
	mov DMAP, #00h
	
	mov ADCCON2, #60h
		
end_of_handler:
	reti
END