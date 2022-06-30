;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RAM Variables	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CMDBUF  .equ    RAMADDR         ; Need only 4 bytes of ram for command buffer

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
        LD      SP,RAMADDR  ; have to set valid SP
        LD      IX,CMDBUF   ; Easy to index command buffer
        
        CALL    ONCE

; Main routine
MAIN:
        CALL    EVERY
        CALL    POLL
        JR      C,MAIN
        
        LD      BC,BIGDEL
DLOOP:
        DEC     BC
        LD      A,C
        OR      B
        JR      NZ,DLOOP
        JR      MAIN
