[org 0x0100]

		jmp start

videoRAMSeg	equ	0xb800
textAttr	db	0x07

text:
	db 'Hello, world!', 0

;---------------------------------------------------------------
; Print a null-terminated string.
;
; Input:
;	DS	The segment containing the string.
;	SI	The address of the string.
;	DI	Screen offset to print at. (row * 80 * 2 + column * 2)
;---------------------------------------------------------------
printString:
		pusha
		push	es
		
		mov		bx, videoRAMSeg
		mov		es, bx
		
printString_loop:
		mov		al, byte [ds:si]
		cmp		al, 0
		jz		printString_end
		mov		ah, [textAttr]				; set the color attribute
		mov		[es:di], ax
		inc		si
		add		di, 2
		jmp		printString_loop
printString_end:
		pop		es
		popa
		ret

;---------------------------------------------------------------
; Print a number to the screen in base-10.
;
; Input:
;	AX	The number to print.
;	DI	Screen offset to print at. (row * 80 * 2 + column * 2)
;---------------------------------------------------------------
printInteger:
		pusha
		push	es
		
		mov		bx, videoRAMSeg
		mov		es, bx
		
		mov		bx, 10						; base 10
		mov		cx, 0

printInteger_collectDigits:
		mov		dx, 0
		div		bx							; ax=ax/bx, remainder in dx
		add		dl, '0'						; convert the digit to ASCII
		push	dx							; store the digits in reverse
		inc		cx							; count the number of digits
		cmp		ax, 0
		jnz		printInteger_collectDigits
		
		cmp		cx, 1						; do we have any digits?
		jnz		printInteger_writeDigits	; yes, then write the number
		mov		byte [es:di], '0'			; no, then write a 0
		ret

printInteger_writeDigits:
		pop		dx							; get the next digit
		mov		dh, [textAttr]				; set the color attribute
		mov		[es:di], dx					; write the digit
		add		di, 2						; move to the next character position
		loop	printInteger_writeDigits
		
		pop		es
		popa
		ret

;---------------------------------------------------------------
; Calculate the offet into text memory
; based on a row and column.
;
; Input:
;	AH	Row.
;	AL	Column.
;
; Output:
;	DI	The offset into text memory.
;---------------------------------------------------------------
calcTextOffset:
	; AH * 80 * 2 + AL * 2
	; ((AH << 5) * 5) + (AL << 1)
	
	; Column * 2
		push	ax
		xor		ah, ah
		shl		ax, 1
		mov		di, ax
		pop		ax

	; Row * 80 * 2
		push	ax
		mov		al, ah
		xor		ah, ah
		shl		ax, 5
		add		di, ax
		add		di, ax
		add		di, ax
		add		di, ax
		add		di, ax
		pop		ax
		
		ret

;---------------------------------------------------------------
start:
	; Set the data segment.
		mov		ax, cs
		mov		ds, ax

	; Write some text.
		mov		ah, 9
		mov		al, 40
		call	calcTextOffset
		
		mov		si, text
		call	printString

	; Write an integer.
		mov		ah, 10
		mov		al, 40
		call	calcTextOffset

		mov		ax, 12345
		call	printInteger

	; Return to DOS.
		mov		ax, 0x4c00
		int		0x21
