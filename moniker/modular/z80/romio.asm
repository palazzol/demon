IOREGR   .equ	STRTADD+0x0400    ;reserved region for IO READ
IOREGW   .equ	STRTADD+0x0500    ;reserved region for IO WRITE

; Set the SCL pin high
; D is the global coin counter buffer
; Destroys A
SETSCL:
        LD      A,D
        OR      0x01
        LD      D,A
        PUSH    HL
        LD      H,#>IOREGW
        LD      L,A
        LD      A,(HL)
        POP     HL
        CALL    I2CDELAY
        RET
    
; Set the SCL pin low
; D is the global coin counter buffer
; Destroys A
CLRSCL:
        LD      A,D
        AND     0xFE
        LD      D,A
        PUSH    HL
        LD      H,#>IOREGW
        LD      L,A
        LD      A,(HL)
        POP     HL
        RET

; Set the DOUT pin low
; D is the global coin counter buffer
; Destroys A 
SETSDA:
        LD      A,D
        AND     0xFD
        LD      D,A
        PUSH    HL
        LD      H,#>IOREGW
        LD      L,A
        LD      A,(HL)
        POP     HL
        CALL    I2CDELAY
        RET

; Set the DOUT pin high
; D is the global coin counter buffer
; Destroys A  
CLRSDA:
        LD      A,D
        OR      0x02
        LD      D,A
        PUSH    HL
        LD      H,#>IOREGW
        LD      L,A
        LD      A,(HL)
        POP     HL
        CALL    I2CDELAY
        RET

; Read the DIN pin 
; returns bit in carry flag    
READSDA:
        LD      A,D
        PUSH    HL
        LD      H,#>IOREGR
        LD      L,A
        LD      A,(HL)
        POP     HL
        SRL     A           ;carry flag
        RET
