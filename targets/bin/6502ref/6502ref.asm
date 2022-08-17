;****************************************************************
; This file is auto-generated by ddmake from 6502ref.toml
; *** DO NOT EDIT ***
;****************************************************************

; Start of chip memory mapping
STRTADD = 0xf800

; 2K ROM
ROMSIZE = 0x0800

; Start of ram, needs 7 bytes starting here
; On the 6502, you can usually you can count on there being RAM in page 0
RAMSTRT = 0x0000

; Start of stack, needs some memory below this address
; On the 6502, this is in page 1, so this actually represents
; address 0x0100+SSTACK
SSTACK = 0x00ff

; delay factor
BIGDEL = 0x0180

        .include "../core/dd.def"
        .include "../core/6502.def"
        .include "../io/romio.def"

;------- region1  -----------------------------------------------

        .bank   region1 (base=STRTADD, size=IOADD-STRTADD)
        .area   region1 (ABS, BANK=region1)

;
;       START CODE
;
START:
        sei              ; Disable interrupts - we don't handle them
        ldx     #SSTACK  ; set up the stack
        txs
        cld              ; No Decimal
;       YOUR CODE CAN GO HERE
        jmp     INIT

        .include "../core/6502_main.asm"
;
;       EVERY CODE
;
EVERY:
;       YOUR CODE CAN GO HERE
        rts

        .include "../io/6502_romio.asm"
;
;       NMI HANDLER
;
NMI:
        rti


;------- region2  -----------------------------------------------

        .bank   region2 (base=IOADD, size=IOEND-IOADD)
        .area   region2 (ABS, BANK=region2)

        .include "../io/romio_table.asm"

;------- region3  -----------------------------------------------

        .bank   region3 (base=VECTORS, size=ROMSIZE-VECTORS)
        .area   region3 (ABS, BANK=region3)

        .include "../core/6502_vectors.asm"
