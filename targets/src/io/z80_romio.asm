
; For Demon Debugger Hardware - Rev D 

; Set the SCL pin high
; D is the global output buffer
; Destroys A
SETSCL:
        LD      A,D
        OR      0x01
        LD      D,A
        PUSH    HL
        LD      H,#>IOREGW
        ADD     A,#<IOREGW 
        LD      L,A
        LD      A,(HL)
        POP     HL
        CALL    I2CDELAY
        RET
    
; Set the SCL pin low
; D is the global output buffer
; Destroys A
CLRSCL:
        LD      A,D
        AND     0x1E
        LD      D,A
        PUSH    HL
        LD      H,#>IOREGW
        ADD     A,#<IOREGW 
        LD      L,A
        LD      A,(HL)
        POP     HL
        RET

; Set the DOUT pin low
; D is the global output buffer
; Destroys A 
SETSDA:
        LD      A,D
        AND     0x1D
        LD      D,A
        PUSH    HL
        LD      H,#>IOREGW
        ADD     A,#<IOREGW 
        LD      L,A
        LD      A,(HL)
        POP     HL
        CALL    I2CDELAY
        RET

; Set the DOUT pin high
; D is the global output buffer
; Destroys A  
CLRSDA:
        LD      A,D
        OR      0x02
        LD      D,A
        PUSH    HL
        LD      H,#>IOREGW
        ADD     A,#<IOREGW 
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
        ADD     A,#<IOREGR
        LD      L,A
        LD      A,(HL)
        POP     HL
        SRL     A           ;carry flag
        RET
