;
; Moniker - 6502 Version
; by Frank Palazzolo
; For ROM IO Hardware
;
        .area   CODE1   (ABS)   ; ASXXXX directive, absolute addressing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; You may need to adjust these variables for different targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RAM SETTINGS - usually in zero page

RAMSTRT .equ    0x00    ;start of ram, needs 7 bytes starting here
SSTACK	.equ	0xff	;start of stack, needs some memory below this address

; ROM SETTINGS - usually the last 2K of memory for 6502

SCHIP   .equ     0xf800   ;start of chip memory mapping

IOREGR	.equ	SCHIP+0x07a0	;reserved region for IO Read
IOREGW	.equ	SCHIP+0x07c0	;reserved region for IO Write
VECTORS	.equ	SCHIP+0x07fa	;reserved for vectors

; TIMER SETTING
BIGDEL	.equ	0x0180   ;delay factor

I2CRADR .equ     0x11    ;I2C read address  - I2C address 0x08
I2CWADR .equ     0x10    ;I2C write address - I2C address 0x08

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RAM Variables	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OUTBUF	.equ	RAMSTRT	        ;buffer for output states
B	.equ	RAMSTRT+0x01	;general purpose
C	.equ	RAMSTRT+0x02	;general purpose
CMDBUF0 .equ	RAMSTRT+0x03	;command buffer
CMDBUF1 .equ	RAMSTRT+0x04	;command buffer
CMDBUF2 .equ	RAMSTRT+0x05	;command buffer
CMDBUF3 .equ	RAMSTRT+0x06	;command buffer

	.org	SCHIP	;last 2K of memory starts here

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is called once, and should be used do any game-specific
; initialization that is required
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ONCE:
;       YOUR CODE CAN GO HERE
        rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is called every time during the polling loop.  It can be
; used to run watchdog code, etc.  I have provided a simple delay loop
; so that the I2C slave is not overwhelmed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EVERY:
;       YOUR CODE CAN GO HERE
        rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Program code starts here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; NMI Handler
NMI:	rti             ;Don't do anything on an NMI

SETSCL:	lda	OUTBUF
	ora	#0x01
        sta     OUTBUF
        tax
        lda     IOREGW,X
	jsr	I2CDLY
	rts

CLRSCL:	lda	OUTBUF
	and	#0x1e
	sta	OUTBUF
        tax
        lda     IOREGW,X
	rts

SETSDA:	lda	OUTBUF
	and	#0x1d
        sta     OUTBUF
        tax
        lda     IOREGW,X
	jsr	I2CDLY
	rts

CLRSDA:	lda	OUTBUF
	ora	#0x02
        sta     OUTBUF
        tax
        lda     IOREGW,X
	jsr	I2CDLY
	rts

READSDA:	ldx	OUTBUF
        lda     IOREGR,X
        ror
	rts				

; Delay for half a bit time
I2CDLY:	rts		; TBD - this is plenty?

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
	lda	#0x08
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
        lda	#0x08
	sta	B
	lda	#0x00
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
        lda     #0x2e  ; '.'
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
        cmp     #0x52    	; 'R' - Read memory
        beq     MREAD
        cmp     #0x57    	; 'W' - Write memory
        beq	MWRITE
        cmp     #0x43    	; 'C' - Call subroutine
        beq	REMCALL
        clc
        rts

MREAD:
        jsr     LOADBC
        ldy	#0x00
        lda	[B],Y
        jmp     SRESP
MWRITE:
        jsr     LOADBC
        lda     CMDBUF3
        sta     [B],Y
        lda     #0x57  	;'W'
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
	lda	#>(START-1)
        pha
        lda	#<(START-1)
        pha
        jsr     LOADBC
        jmp     [B]
        
;;;;;;;;;;
	
START:
        sei             ; disable interrupts
	ldx	#SSTACK
	txs		; Init stack
	cld		; No Decimal
        lda     #0x00
        sta     OUTBUF
        jsr     ONCE

; Main routine
MAIN:
        jsr     EVERY
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

        .org    IOREGW
        
        .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f

;       vectors

	.org	SCHIP+0x07fa

	.dw	NMI
	.dw	START
	.dw	START
	
	
	