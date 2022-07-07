[org 0x0100]

		jmp start

PIT_CHANNEL0	equ	0x40
PIT_CHANNEL1	equ	0x41
PIT_CHANNEL2	equ	0x42
PIT_COMMAND		equ	0x43

PIT_HZ			equ	1193180

; NMI Status and Control Register
; Bit 1 = Speaker Data Enable (SPKR_​DAT_​EN)
;	When this bit is a 0, the SPKR output is a 0.
;	When this bit is a 1, the SPKR output is equivalent to the Counter 2 OUT signal value.
; Bit 0 = Timer Counter 2 Enable (TIM_​CNT2_​EN)
;	When this bit is a 0, Counter 2 counting is disabled.
;	Counting is enabled when this bit is 1.
; Source: https://edc.intel.com/content/www/us/en/design/products-and-solutions/processors-and-chipsets/comet-lake-u/intel-400-series-chipset-on-package-platform-controller-hub-register-database/nmi-status-and-control-nmi-sts-cnt-offset-61/
NMI_STS_CNT	equ 0x61

; SEE: https://wiki.osdev.org/PC_Speaker
; SEE ALSO: https://web.archive.org/web/20171115162742/http://guideme.itgo.com/atozofc/ch23.pdf

; Musical note table:
;float notes[7][12] = {
;    { 130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 185.0, 196.0, 207.65, 220.0, 227.31, 246.96 },
;    { 261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.63, 392.0, 415.3, 440.0, 454.62, 493.92 },
;    { 523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61, 880.0, 909.24, 987.84 },
;    { 1046.5, 1108.73, 1174.66, 1244.51, 1328.51, 1396.91, 1479.98, 1567.98, 1661.22, 1760.0, 1818.48, 1975.68 },
;    { 2093.0, 2217.46, 2349.32, 2489.02, 2637.02, 2793.83, 2959.96, 3135.96, 3322.44, 3520.0, 3636.96, 3951.36 },
;    { 4186.0, 4434.92, 4698.64, 4978.04, 5274.04, 5587.86, 5919.92, 6271.92, 6644.88, 7040.0, 7273.92, 7902.72 },
;    { 8372.0, 8869.89, 9397.28,9956.08,10548.08,11175.32, 11839.84, 12543.84, 13289.76, 14080.0, 14547.84, 15805.44 }
;};

;-------------------------------------------------------------------------------
; Activate the speaker with whatever frequency is loaded into the PIT.
;-------------------------------------------------------------------------------
activateSpeaker:
		push		ax
		in			al, NMI_STS_CNT
		or			al, 0x03
		out			0x61, al
		pop			ax
		ret

deactivateSpeaker:
		push		ax
		in			al, NMI_STS_CNT
		and			al, 0xfc					; clear the lower 2 bits
		out			0x61, al
		pop			ax
		ret

;-------------------------------------------------------------------------------
start:
	; Set the PIT to the desired frequency.
	; The 2 high bits seem to be the channel number we're setting.  Not sure what the lower 4 bits are for yet.
		mov			al, 0xb6					; Tell the PIT which channel we're setting.
		out			PIT_COMMAND, al

		mov			ax, PIT_HZ / 440

		out			PIT_CHANNEL2, al
		shr			ax, 8
		out			PIT_CHANNEL2, al
		
		call		activateSpeaker
		;call		deactivateSpeaker
skip:

	; Return to DOS.
		mov		ax, 0x4c00
		int		0x21
