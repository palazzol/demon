; SCL  - OUT F9, bit7, (0x80) coin counter 1, pin 5, U11 - R1
; DOUT - OUT F9, bit6, (0x40) coin counter 2, pin 9, U11 - R3
; DIN  - IN  F8, bit3, (0x08) DIP, SW1, pin9, U2-pin 6
;
; Note: We cannot use opcode 0x32 on this platform, or it will trigger
;       the security chip
;

DSPORT  .equ    0xf8        ; dip switch 1 port
CCPORT  .equ    0xf9        ; port for count counters

; Set the SCL pin high
; D is the global coin counter buffer
; Destroys A
SETSCL:
        LD      A,D
        OR      0x80
        LD      D,A
        OUT     (CCPORT),A
        CALL    I2CDELAY
        RET
    
; Set the SCL pin low
; D is the global coin counter buffer
; Destroys A
CLRSCL:
        LD      A,D
        AND     0x7F
        LD      D,A
        OUT     (CCPORT),A
        RET

; Set the DOUT pin low
; D is the global coin counter buffer
; Destroys A 
SETSDA:
        LD      A,D
        AND     0xBF
        LD      D,A
        OUT     (CCPORT),A
        CALL    I2CDELAY
        RET

; Set the DOUT pin high
; D is the global coin counter buffer
; Destroys A  
CLRSDA:
        LD      A,D
        OR      0x40
        LD      D,A
        OUT     (CCPORT),A
        CALL    I2CDELAY
        RET

; Read the DIN pin 
; returns bit in carry flag    
READSDA:
        IN      A,(DSPORT)  ;0x08
        SRL     A           ;0x04
        SRL     A           ;0x02
        SRL     A           ;0x01
        SRL     A           ;carry flag
        RET