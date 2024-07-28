
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RAM Variables 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OUTBUF  .equ    RAMSTRT         ;buffer for output states
BREG    .equ    RAMSTRT+0x01    ;general purpose
C       .equ    RAMSTRT+0x02    ;general purpose
CMDBUF0 .equ    RAMSTRT+0x03    ;command buffer
CMDBUF1 .equ    RAMSTRT+0x04    ;command buffer
CMDBUF2 .equ    RAMSTRT+0x05    ;command buffer
CMDBUF3 .equ    RAMSTRT+0x06    ;command buffer

; I2C ADDRESSING
I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08

INIT:
        ldaa    #0x00
        staa    OUTBUF

; Main routine
MAIN:
        jsr     EVERY
        jsr     POLL
        bcs     MAIN
        ldaa    #BIGDEL>>8
        staa    BREG
        ldaa    #BIGDEL%256
        staa    C
MLOOP:
        ldaa    C
        beq     DECBOTH
        dec     C
        jmp     MLOOP
DECBOTH:
        ldaa    BREG
        beq     MAIN
        dec     C
        dec     BREG
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
        rola            ; save carry flag here
        psha
        jsr     CLRSCL
        pula
        rora            ; restore carry flag here
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
        ldab    #0x08   
ILOOP:
        rola                ; high bit into carry
        psha
        jsr     I2CWBIT
        pula
        decb
        bne     ILOOP
        jsr     I2CRBIT
        rts
        
I2CRBYTE:
        ldab    #0x08
        ldaa    #0x00
LOOP3:
        psha
        jsr     I2CRBIT     ; get bit in carry flag
        pula
        rola                ; rotate carry into bit0
        decb
        bne     LOOP3
        clc                 ; clear carry flag 
        psha             
        jsr     I2CWBIT
        pula
        rts

I2CRREQ:
        jsr     I2CSTART
        ldaa    #I2CRADR
        jsr     I2CWBYTE
        bcs     SKIP
        jsr     I2CRBYTE
        staa    CMDBUF0
        jsr     I2CRBYTE
        staa    CMDBUF1
        jsr     I2CRBYTE
        staa    CMDBUF2
        jsr     I2CRBYTE
        staa    CMDBUF3
        jmp     ENDI2C
    
SKIP:                       ; If no device present, fake an idle response
        ldaa    #0x2e  ; '.'
        staa    CMDBUF0
        jmp     ENDI2C

I2CSRESP:
        psha
        jsr     I2CSTART
        ldaa    #I2CWADR
        jsr     I2CWBYTE
        pula
        jsr     I2CWBYTE
ENDI2C:
        jsr     I2CSTOP
        rts

POLL:
        jsr     I2CRREQ
        ldaa    CMDBUF0
        cmpa    #0x52           ; 'R' - Read memory
        beq     MREAD
        cmpa    #0x57           ; 'W' - Write memory
        beq     MWRITE
        cmpa    #0x43           ; 'C' - Call subroutine
        beq     REMCALL
        clc
        rts

MREAD:
        jsr     LOADBC
        ldx     BREG
        ldaa    0,X
        jmp     SRESP
MWRITE:
        jsr     LOADBC
        ldaa    CMDBUF3
        ldx     BREG
        staa    0,X
        ldaa    #0x57   ;'W'
        jmp     SRESP
LOADBC:
        ldaa    CMDBUF1
        staa    BREG
        ldaa    CMDBUF2
        staa    C
        rts
        
SRESP:
        jsr    I2CSRESP
RHERE:
        sec
        rts
REMCALL:
        ldaa    #>(START-1)
        psha
        ldaa    #<(START-1)
        psha
        jsr     LOADBC
        ldx     BREG
        jmp     0,X
        
;;;;;;;;;;
