

[org 0x0100]

		jmp start

ms_per_cycle equ 55

hrs:	dw 0
min:	dw 0
s:		dw 0
ms:		dw 0
ticks:	dw 0

lastUpdateTime:
		dw 0

;-------------------------------------------------------------------------------
; The clock ticks at 18.222Hz, so this should get called every 55-ish
; milliseconds.
;-------------------------------------------------------------------------------
onTimer:
		push	ax

		add		word [cs:ticks], 1

		add		word [cs:ms], ms_per_cycle
		cmp		word [cs:ms], 1000
		jle		onTimer_end
		
		mov		word [cs:ms], 0
		inc		word[cs:s]
		cmp		word [cs:s], 60
		jnz		onTimer_end
		
		mov		word [cs:s], 0
		inc		word[cs:min]
		cmp		word [cs:min], 60
		jnz		onTimer_end
		
		mov		word [cs:min], 0
		inc		word [cs:hrs]

onTimer_end:
	; Acknowledge the interrupt.
		mov		al, 0x20
		out		0x20, al
		pop		ax
		iret

;-------------------------------------------------------------------------------
start:		 
		mov		ax, 0
		mov		es, ax

	; Hook the timer interrupt.
		cli
	; System timer is IRQ 0.  This gets mapped to interrupt 8 (I think?), with 4 bytes per address.
		mov		word [es:8 * 4], onTimer
		mov		[es:8 * 4 + 2], cs
		sti
				
loop:
	; Wait for 300ms to pass before continuing.
		mov		ax, word [cs:ticks]
		mov		bx, word [cs:lastUpdateTime]
		sub		ax, bx
		cmp		ax, 300 / ms_per_cycle				; This is approximately every 300ms.
		jbe		loop

	; Save the last update time.
		mov		ax, word [cs:ticks]
		mov		word [cs:lastUpdateTime], ax
		
	; Write a character to standard output.
		mov		dl, '*'
		mov		ah, 0x02
		int		0x21

		jmp		loop
