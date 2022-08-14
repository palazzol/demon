
; SCL  - WRITE 0x3200, bit0 (0x01) 2 player start lamp - active low only because led is wired to +5V
; DOUT - WRITE 0x3200, bit1 (0x02) 1 player start lamp - active low only because led is wired to +5V
; DIN  - READ  0x2405, bit7 (0x80) thrust button - inverted on input

DIP7	.equ	0x2800	;bit0 = DIP switch 7
LEDS	.equ	0x3200	;bit0 = 2 player start lamp
			;bit1 = 1 player start lamp
		
LEDBUF	.equ	OUTBUF	;buffer for lamps

SETSCL:	lda	LEDBUF
	ora	#0x01
	sta	LEDBUF
	sta	LEDS
	jsr	I2CDLY
	rts

CLRSCL:	lda	LEDBUF
	and	#0xfe
	sta	LEDBUF
	sta	LEDS
	rts
	
SETSDA:	lda	LEDBUF
	and	#0xfd
	sta	LEDBUF
	sta	LEDS
	jsr	I2CDLY
	rts

CLRSDA:	lda	LEDBUF
	ora	#0x02
	sta	LEDBUF
	sta	LEDS
	jsr	I2CDLY
	rts

READSDA:        
        lda	DIP7
	ror			
	rts		
    