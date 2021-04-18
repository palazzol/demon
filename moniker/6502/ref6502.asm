;
; Moniker - 6502 Version
; by Frank Palazzolo
; For ROM IO Hardware
;
	processor	6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; You may need to adjust these variables for different targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RAM SETTINGS - usually in zero page

RAMSTRT equ     $00     ;start of ram, needs 7 bytes starting here
SSTACK	equ	$ff	;start of stack, needs some memory below this address

; ROM SETTINGS - usually the last 2K of memory for 6502

SCHIP   equ     $f800   ;start of chip memory mapping

IOREG	equ	SCHIP+$0400	;reserved region for IO
VECTORS	equ	SCHIP+$07fa	;reserved for vectors

; TIMER SETTING
BIGDEL	equ	$0180   ;delay factor

I2CRADR equ     $11    ;I2C read address  - I2C address 0x08
I2CWADR equ     $10    ;I2C write address - I2C address 0x08

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RAM Variables	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OUTBUF	equ	RAMSTRT	        ;buffer for output states
B	equ	RAMSTRT+$01	;general purpose
C	equ	RAMSTRT+$02	;general purpose
CMDBUF0 equ	RAMSTRT+$03	;command buffer
CMDBUF1 equ	RAMSTRT+$04	;command buffer
CMDBUF2 equ	RAMSTRT+$05	;command buffer
CMDBUF3 equ	RAMSTRT+$06	;command buffer

	org	SCHIP	;last 2K of memory starts here

        ds      $0600,$ff       ; fill front and io regions with $FF

        ; Code fits into the last 512 bytes of memory
        org     SCHIP+$0600     ;code starts here

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
NMI	rti             ;Don't do anything on an NMI

SETSCL	lda	OUTBUF
	ora	#$01
        sta     OUTBUF
        tax
        lda     IOREG,X
	jsr	I2CDLY
	rts

CLRSCL	lda	OUTBUF
	and	#$fe
	sta	OUTBUF
        tax
        lda     IOREG,X
	rts

SETSDA	lda	OUTBUF
	and	#$fd
        sta     OUTBUF
        tax
        lda     IOREG,X
	jsr	I2CDLY
	rts

CLRSDA	lda	OUTBUF
	ora	#$02
        sta     OUTBUF
        tax
        lda     IOREG,X
	jsr	I2CDLY
	rts

READSDA	ldx	OUTBUF
        lda     IOREG,X
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

;       vectors

	org	SCHIP+$07fa

	dc.w	NMI
	dc.w	START
	dc.w	START
	
	
	