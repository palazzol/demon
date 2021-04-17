;
; Moniker - 6502 Version
; by Frank Palazzolo
; For Atari Asteroids
;
; SCL  - WRITE $3200, bit0 ($01) 2 player start lamp - active low only because led is wired to +5V
; DOUT - WRITE $3200, bit1 ($02) 1 player start lamp - active low only because led is wired to +5V
; DIN  - READ  $2405, bit7 ($80) thrust button - inverted on input

	processor	6502

DIP7	equ	$2800	;bit0 = DIP switch 7
LEDS	equ	$3200	;bit0 = 2 player start lamp
			;bit1 = 1 player start lamp
		
LEDBUF	equ	$00	;buffer for lamps
B	equ	$01	;general purpose
C	equ	$02	;general purpose
CMDBUF0 equ	$03	;command buffer
CMDBUF1 equ	$04	;command buffer
CMDBUF2 equ	$05	;command buffer
CMDBUF3 equ	$06	;command buffer

SSTACK	equ	$fe	;start of stack

I2CRADR equ     $11    ;I2C read address  - I2C address 0x08
I2CWADR equ     $10    ;I2C write address - I2C address 0x08

BIGDEL	equ	$0180

	org	$7800	;start of rom at j2
	
NMI	rti

SETSCL	lda	LEDBUF
	ora	#$01
	sta	LEDBUF
	sta	LEDS
	jsr	I2CDLY
	rts

CLRSCL	lda	LEDBUF
	and	#$fe
	sta	LEDBUF
	sta	LEDS
	rts
	
SETSDA	lda	LEDBUF
	and	#$fd
	sta	LEDBUF
	sta	LEDS
	jsr	I2CDLY
	rts

CLRSDA	lda	LEDBUF
	ora	#$02
	sta	LEDBUF
	sta	LEDS
	jsr	I2CDLY
	rts

READSDA	lda	DIP7
	ror			
	rts				

; Delay for half a bit time
I2CDLY	rts		; TBD - this is plenty?

; I2C Start Condition
I2CSTART:
        jsr    CLRSDA      
        jsr    CLRSCL
        rts

; I2C Stop Condition
; Uses HL
; Destroys A
I2CSTOP:
        jsr    CLRSDA
        jsr    SETSCL
        jsr    SETSDA
        rts
        
I2CRBIT:
	jsr	SETSDA
	jsr	SETSCL
	jsr	READSDA	; sets/clears carry flag
	jsr     CLRSCL
	rts		; carry flag still good here

I2CWBIT:
	bcc	DOCLR
	jsr	SETSDA
	jmp	AHEAD
DOCLR:
	jsr	CLRSDA
AHEAD:
	jsr	SETSCL
	jsr	CLRSCL
	rts
        
I2CWBYTE:
	pha
	lda	#$08
	sta	B
	pla
ILOOP:
	rol
	pha
	jsr	I2CWBIT
	pla
	dec	B
	bne	ILOOP
	jsr	I2CRBIT
	rts
	
I2CRBYTE:
        lda	#$08
	sta	B
	lda	#$00
	sta	C
LOOP3:
        jsr     I2CRBIT     ; get bit in carry flag
        rol     C           ; rotate carry into bit0 of C register
        dec	B
        bne    	LOOP3
        clc           	    ; clear carry flag              
        jsr   	I2CWBIT
        lda  	C
        rts

I2CRREQ:
        jsr     I2CSTART
        lda	#I2CRADR
        jsr     I2CWBYTE
        bcs     SKIP
        jsr     I2CRBYTE
        sta     CMDBUF0
        jsr     I2CRBYTE
        sta     CMDBUF1
        jsr     I2CRBYTE
        sta     CMDBUF2
        jsr     I2CRBYTE
        sta     CMDBUF3
        jmp     ENDI2C
    
SKIP:                       ; If no device present, fake an idle response
        lda     #$2e  ; '.'
        sta     CMDBUF0
        jmp     ENDI2C

I2CSRESP:
        pha
        jsr     I2CSTART
        lda     #I2CWADR
        jsr     I2CWBYTE
        pla
        jsr     I2CWBYTE
ENDI2C:
        jsr     I2CSTOP
        rts

POLL:
        jsr     I2CRREQ
        lda     CMDBUF0
        cmp     #$52    	; 'R' - Read memory
        beq     MREAD
        cmp     #$57    	; 'W' - Write memory
        beq	MWRITE
        cmp     #$43    	; 'C' - Call subroutine
        beq	REMCALL
        clc
        rts

MREAD:
        jsr     LOADBC
        ldy	#$00
        lda	(B),Y
        jmp     SRESP
MWRITE:
        jsr     LOADBC
        lda     CMDBUF3
        sta     (B),Y
        lda     #$57  	;'W'
        jmp     SRESP
LOADBC:
	lda	CMDBUF2
	sta	B
	lda	CMDBUF1
	sta	C
	rts
	
SRESP:
        jsr    I2CSRESP
RHERE:
        sec
        rts
REMCALL:
	lda	#(START-1)>>8
        pha
        lda	#(START-1)%256
        pha
        jsr     LOADBC
        jmp     (B)
        
;;;;;;;;;;
	
START	; TBD- INIT Stack Pointer!
	ldx	#SSTACK
	txs		; Init stack
	cld		; No Decimal

; Main routine
MAIN:
        jsr     POLL
        bcs     MAIN
        
        lda	#BIGDEL>>8
        sta	B
        lda	#BIGDEL%256
        sta	C
MLOOP:
        lda	C
        beq	DECBOTH
        dec	C
        jmp	MLOOP
DECBOTH:
	lda	B
	beq	MAIN
	dec	C
	dec	B
	jmp	MLOOP

	org	$7ffa
	dc.w	NMI
	dc.w	START
	dc.w	START
	
	
	