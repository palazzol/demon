;
; Moniker - Z80 Version
; by Frank Palazzolo
; For Gorf
;
; SCL  - IN  0x16, bit0 lamp0 (selected by A11,A10,A9, Data is A8)
; DOUT - IN  0x16, bit1 lamp1 (selected by A11,A10,A9, Data is A8)
; DIN  - IN  0x13, bit0, (0x01) DIP, SW1
;
        .area   CODE1   (ABS)   ; ASXXXX directive, absolute addressing

DSPORT  .equ    0x13        ; dip switch 1 port
CCPORT  .equ    0x16        ; port for lamps

CMDBUF  .equ    0xdff0      ; Need only 4 bytes of ram for command buffer
                            ; (We will save 12 more just in case)
SSTACK  .equ    0xdff0      ; Start of stack

I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08

BIGDEL  .equ    0x0180      ; bigger delay, for now still fairly small

        .org    0x0000
    
START:  DI                  ; Disable interrupts - we don't handle them
        JP      INIT        ; go to initialization code
    
; Set the SCL pin high
; Destroys A, B and C
SETSCL:
        LD      B,0x01
        LD	C,CCPORT
        IN      A,(C)
        CALL    I2CDELAY
        RET
    
; Set the SCL pin low
; Destroys A, B and C
CLRSCL:
        LD      B,0x00
        LD	C,CCPORT
        IN      A,(C)
        RET

; Set the DOUT pin low
; Destroys A, B and C
SETSDA:
        LD      B,0x02
        LD	C,CCPORT
        IN      A,(C)
        CALL    I2CDELAY
        RET

; Set the DOUT pin high
; Destroys A, B and C 
CLRSDA:
        LD      B,0x03
        LD	C,CCPORT
        IN      A,(C)
        CALL    I2CDELAY
        RET

; Read the DIN pin 
; returns bit in carry flag    
READSDA:
        IN      A,(DSPORT)  ;0x01
        SRL     A           ;carry flag
        RET
    
; Delay for half a bit time
I2CDELAY:
        RET     ; This is plenty

; I2C Start Condition
; Uses HL
; Destroys A
I2CSTART:
        CALL    CLRSDA      
        CALL    CLRSCL
        RET

; I2C Stop Condition
; Uses HL
; Destroys A
I2CSTOP:
        CALL    CLRSDA
        CALL    SETSCL
        CALL    SETSDA
        RET

; I2C Read Bit routine
; Returns bit in carry blag
; Destroys A
I2CRBIT:
        CALL    SETSDA
        CALL    SETSCL
        CALL    READSDA
        PUSH    AF          ; save carry flag
        CALL    CLRSCL
        POP     AF          ; rv in carry flag
        RET

; I2C Write Bit routine
; Takes carry flag
; Destroys A
I2CWBIT:
        JR      NC,DOCLR
        CALL    SETSDA
        JR      AHEAD
DOCLR:
        CALL    CLRSDA
AHEAD:
        CALL    SETSCL
        CALL    CLRSCL
        RET
        
        ; Make sure this code ends before address 0x66 !
        
        .org    0x0066
NMI:    JP      START       ; restart on test button press

; I2C Write Byte routine
; Takes A
; Destroys B
; Returns carry bit
I2CWBYTE:
        LD      B,8
ILOOP:
        PUSH    BC          ; save B
        RLC     A    
        PUSH    AF          ; save A
        CALL    I2CWBIT
        POP     AF
        POP     BC
        DJNZ    ILOOP
        CALL    I2CRBIT
        RET

; I2C Read Byte routine
; Destroys BC
; Returns A
I2CRBYTE:
        LD      B,8
        LD      C,0
LOOP3:
        PUSH    BC
        CALL    I2CRBIT     ; get bit in carry flag
        POP     BC
        RL      C           ; rotate carry into bit0 of C register
        DJNZ    LOOP3
        XOR     A           ; clear carry flag              
        PUSH    BC
        CALL    I2CWBIT
        POP     BC
        LD      A,C
        RET
;

; Read 4-byte I2C Command from device into CMDBUF
; Uses HL
; Destroys A,BC,HL
I2CRREQ:
        CALL    I2CSTART
        LD      A,I2CRADR
        CALL    I2CWBYTE
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
    
SKIP:                       ; If no device present, fake an idle response
        LD      A,0x2e  ; '.'
        LD      (IX),A
        JR      ENDI2C

I2CSRESP:
        PUSH    AF
        CALL    I2CSTART
        LD      A,I2CWADR
        CALL    I2CWBYTE
        POP     AF
        CALL    I2CWBYTE
ENDI2C:
        CALL    I2CSTOP
        RET
;

; Main Polling loop
; Return carry flag if we got a valid command (not idle)
POLL:
        CALL    I2CRREQ
        LD      A,(IX)
        CP      0x52    ; 'R' - Read memory
        JR      Z,MREAD
        CP      0x57    ; 'W' - Write memory
        JR      Z,MWRITE
        CP      0x49    ; 'I' - Input from port
        JR      Z,PREAD
        CP      0x4F    ; 'O' - Output from port
        JR      Z,PWRITE
        CP      0x43    ; 'C' - Call subroutine
        JR      Z,REMCALL
        CCF
        RET
LOADHL:
        LD      A,(IX+1)
        LD      H,A
        LD      A,(IX+2)
        LD      L,A
        RET    
MREAD:
        CALL    LOADBC
        LD      A,(BC)
        JR      SRESP
MWRITE:
        CALL    LOADBC
        LD      A,(IX+3)
        LD      (BC),A
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
        SCF
        RET
REMCALL:
        LD      HL,START
        PUSH    HL
        CALL    LOADHL
        JP      (HL)
    
INIT:
        LD      SP,SSTACK   ; have to set valid SP
        LD      IX,CMDBUF   ; Easy to index command buffer
        
; Main routine
MAIN:
	IN	A,(0x10)    ; hit watchdog
        CALL    POLL
        JR      C,MAIN
        
        LD      BC,BIGDEL
MLOOP:
        DEC     BC
        LD      A,C
        OR      B
        JR      NZ,MLOOP
        JR      MAIN


    

