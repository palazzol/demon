; SCL  - IN  0x16, bit0 lamp0 (selected by A11,A10,A9, Data is A8)
; DOUT - IN  0x16, bit1 lamp1 (selected by A11,A10,A9, Data is A8)
; DIN  - IN  0x13, bit0, (0x01) DIP, SW1
;

DSPORT  .equ    0x13        ; dip switch 1 port
CCPORT  .equ    0x16        ; port for lamps

; Set the SCL pin high
; Destroys A, B and C
SETSCL:
        LD      B,0x01
        LD	    C,CCPORT
        IN      A,(C)
        CALL    I2CDELAY
        RET
    
; Set the SCL pin low
; Destroys A, B and C
CLRSCL:
        LD      B,0x00
        LD	    C,CCPORT
        IN      A,(C)
        RET

; Set the DOUT pin low
; Destroys A, B and C
SETSDA:
        LD      B,0x02
        LD	    C,CCPORT
        IN      A,(C)
        CALL    I2CDELAY
        RET

; Set the DOUT pin high
; Destroys A, B and C 
CLRSDA:
        LD      B,0x03
        LD	    C,CCPORT
        IN      A,(C)
        CALL    I2CDELAY
        RET

; Read the DIN pin 
; returns bit in carry flag    
READSDA:
        IN      A,(DSPORT)  ;0x01
        SRL     A           ;carry flag
        RET
