;
; Monk - Z80 Version
; For Sega Star Trek
;
;
; SCL  - OUT F9, bit7, (0x80) coin counter 1, pin 5, U11 - R1
; DOUT - OUT F9, bit6, (0x40) coin counter 2, pin 9, U11 - R3
; DIN  - IN  F8, bit3, (0x08) DIP, SW1, pin9, U2-pin 6, 
;
        .area   CODE1   (ABS)
        .org    0x0000
    
        LD      SP,0hc8ff   ; have to set valid SP
        DI

COINBUF .equ    0xc800     ; Need one byte for the last output pin states
CMDBUF  .equ    0xc801     ; Need 4 bytes

START:
        JP      INIT
    
; Input HL = OUT BUFFER
; Destroys A
SETSCL:
        LD      A,(HL)
        OR      0x80
        LD      (HL),A
        OUT     (0xF9),A
        CALL    I2CDELAY
        RET
    
; Input HL = OUT BUFFER
; Destroys A
CLRSCL:
        LD      A,(HL)
        AND     0x7F
        LD      (HL),A
        OUT     (0xF9),A
        RET

; Input HL = OUT BUFFER
; Destroys A 
SETSDA:
        LD      A,(HL)
        AND     0xBF
        LD      (HL),A
        OUT     (0xF9),A
        CALL    I2CDELAY
        RET

; Input HL = OUT BUFFER
; Destroys A  
CLRSDA:
        LD      A,(HL)
        OR      0x40
        LD      (HL),A
        OUT     (0xF9),A
        CALL    I2CDELAY
        RET

; RETURNS BIT0 of A    
READSDA:
        IN      A,(0xF8)    ;0x08
        SRL     A           ;0x04
        SRL     A           ;0x02
        SRL     A           ;0x01
        RET             ; return in bit0 of A
    
; Destroys B
I2CDELAY:
        LD      B,0x10
DLOOP:
        DJNZ    DLOOP
        RET

; Uses HL
; Destroys A,B
I2CSTART:
        LD      HL,COINBUF
        CALL    CLRSDA      
        CALL    CLRSCL
        RET

; Uses HL
; Destroys A,B
I2CSTOP:
        LD      HL,COINBUF
        CALL    CLRSDA
        CALL    SETSCL
        CALL    SETSDA
        CALL    I2CDELAY
        RET
    
; Returns Bit0 of A
; Destroys HL
; Destroys B
I2CRBIT:
        LD      HL,COINBUF
        CALL    SETSDA
        CALL    SETSCL
        CALL    READSDA
        PUSH    AF
        CALL    CLRSCL
        POP     AF          ; rv in bit0 of A
        RET

        ; no space left here!
        
        .org     0x0066
        RETN
        
; Takes bit0 of A
; Destroys HL,B
I2CWBIT:
        LD      HL,COINBUF
        RRC     A
        JR      NC,DOCLR
        CALL    SETSDA
        JR      AHEAD
DOCLR:
        CALL    CLRSDA
AHEAD:
        CALL    SETSCL
        CALL    CLRSCL
        RET

; Takes A
; Destroys BC,HL
; Returns A bit0

I2CWBYTE:
        LD      B,8
ILOOP:
        PUSH    BC
        RLC     A     
        JR      C,W1
        PUSH    AF
        XOR     A    
        JR      AHEAD2
W1:
        PUSH    AF
        LD      A,0x01

AHEAD2:
        CALL    I2CWBIT
        POP     AF
        POP     BC
        DJNZ    ILOOP
        CALL    I2CRBIT
        RET
    
; Destroys BC,HL
; Returns A
I2CRBYTE:
        LD      B,8
        LD      C,0
LOOP3:
        PUSH    BC
        CALL    I2CRBIT
        POP     BC
        RRCA
        RL      C
        DJNZ    LOOP3
        XOR     A
        PUSH    BC
        CALL    I2CWBIT
        POP     BC
        LD      A,C
        RET
;

; Uses HL
; Destroys A,BC,HL
I2CRREQ:
        CALL    I2CSTART
        LD      A,0x11
        CALL    I2CWBYTE
        RRC     A
        JR      C,SKIP
        CALL    I2CRBYTE
        LD      (IX),A
        CALL    I2CRBYTE
        LD      (IX+1),A  
        CALL    I2CRBYTE
        LD      (IX+2),A
        CALL    I2CRBYTE
        LD      (IX+3),A
        JR      ENDI2C
    
SKIP:
        LD      A,0x2e  ; '.'
        LD      (IX),A
        JR      ENDI2C

I2CSRESP:
        PUSH    AF
        CALL    I2CSTART
        LD      A,0x10
        CALL    I2CWBYTE
        POP     AF
        CALL    I2CWBYTE
ENDI2C:
        CALL    I2CSTOP
        RET
;

POLL:
        CALL    I2CRREQ
        LD      A,(IX)
        CP      0x52    ; 'R'
        JR      Z,MREAD
        CP      0x57    ; 'W'
        JR      Z,MWRITE
        CP      0x49    ; 'I'
        JR      Z,PREAD
        CP      0x4F    ; 'O'
        JR      Z,PWRITE
        CP      0x43    ; 'C'
        JR      Z,REMCALL
        RET
LOADHL:
        LD      A,(IX+1)
        LD      H,A
        LD      A,(IX+2)
        LD      L,A
        RET
MREAD:
        CALL    LOADHL
        LD      A,(HL)
        JR      SRESP
MWRITE:
        CALL    LOADHL
        LD      A,(IX+3)
        LD      (HL),A
        LD      A,0x57  ;'W'
        JR      SRESP
LOADBC:
        LD      A,(IX+1)
        LD      B,A
        LD      A,(IX+2)
        LD      C,A
        RET
PREAD:
        CALL    LOADBC
        IN      A,(C)
        JR      SRESP
PWRITE:
        CALL    LOADBC
        LD      A,(IX+3)
        OUT     (C),A
        LD      A,0x4F  ;'O'
SRESP:
        CALL    I2CSRESP
RHERE:
        RET
REMCALL:
        CALL    LOADHL
        LD      BC,RHERE
        PUSH    BC
        JP      (HL)
    
INIT:
        LD      IX,CMDBUF
MAIN:
        CALL    POLL
        LD      B,0xff
MLOOP:
        PUSH    BC
        CALL    I2CDELAY
        POP     BC
        DJNZ    MLOOP
        JR      MAIN


    

