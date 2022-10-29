;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RAM Variables 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OUTBUF  .equ    RAMSTRT         ;buffer for output states
B       .equ    RAMSTRT+0x01    ;general purpose
C       .equ    RAMSTRT+0x02    ;general purpose
CMDBUF0 .equ    RAMSTRT+0x03    ;command buffer
CMDBUF1 .equ    RAMSTRT+0x04    ;command buffer
CMDBUF2 .equ    RAMSTRT+0x05    ;command buffer
CMDBUF3 .equ    RAMSTRT+0x06    ;command buffer

; I2C ADDRESSING
I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08

INIT:
        lda     #0x00
        sta     OUTBUF

; Main routine
MAIN:
        jsr     EVERY
        jsr     POLL
        bcs     MAIN
        lda     #BIGDEL>>8
        sta     B
        lda     #BIGDEL%256
        sta     C
MLOOP:
        lda     C
        beq     DECBOTH
        dec     C
        jmp     MLOOP
DECBOTH:
        lda     B
        beq     MAIN
        dec     C
        dec     B
        jmp     MLOOP

; Delay for half a bit time
I2CDLY: rts             ; TBD - this is plenty?

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
        jsr     SETSDA
        jsr     SETSCL
        jsr     READSDA ; sets/clears carry flag
        jsr     CLRSCL
        rts             ; carry flag still good here

I2CWBIT:
        bcc     DOCLR
        jsr     SETSDA
        jmp     AHEAD
DOCLR:
        jsr     CLRSDA
AHEAD:
        jsr     SETSCL
        jsr     CLRSCL
        rts
        
I2CWBYTE:
        pha
        lda     #0x08
        sta     B
        pla
ILOOP:
        rol
        pha
        jsr     I2CWBIT
        pla
        dec     B
        bne     ILOOP
        jsr     I2CRBIT
        rts
        
I2CRBYTE:
        lda     #0x08
        sta     B
        lda     #0x00
        sta     C
LOOP3:
        jsr     I2CRBIT     ; get bit in carry flag
        rol     C           ; rotate carry into bit0 of C register
        dec     B
        bne     LOOP3
        clc                 ; clear carry flag              
        jsr     I2CWBIT
        lda     C
        rts

I2CRREQ:
        jsr     I2CSTART
        lda         #I2CRADR
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
        cmp     #0x52           ; 'R' - Read memory
        beq     MREAD
        cmp     #0x57           ; 'W' - Write memory
        beq     MWRITE
        cmp     #0x43           ; 'C' - Call subroutine
        beq     REMCALL
        clc
        rts

MREAD:
        jsr     LOADBC
        ldy     #0x00
        lda     [B],Y
        jmp     SRESP
MWRITE:
        jsr     LOADBC
        lda     CMDBUF3
        ldy     #0x00
        sta     [B],Y
        lda     #0x57   ;'W'
        jmp     SRESP
LOADBC:
        lda     CMDBUF2
        sta     B
        lda     CMDBUF1
        sta     C
        rts
        
SRESP:
        jsr    I2CSRESP
RHERE:
        sec
        rts
REMCALL:
        lda     #>(START-1)
        pha
        lda     #<(START-1)
        pha
        jsr     LOADBC
        jmp     [B]
        
;;;;;;;;;;


