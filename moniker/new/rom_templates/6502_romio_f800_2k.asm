
; 2K ROM          
STRTADD .equ    0xf800      ; start of chip memory mapping
ROMSIZE .equ    0x0800

        .include "../dd/dd.def"
        .include "../dd/6502.def"
        .include "../io/romio.def"

; TIMER SETTING
BIGDEL  .equ    0x0180      ; delay factor

        .bank   first   (base=STRTADD, size=IOADD-STRTADD)
        .area   first   (ABS, BANK=first)
STARTUP:
        STARTUP_MACRO

        ; Entry to main routine here
        .include "../dd/6502_main.asm"

EVERY:
        EVERY_MACRO
        
        ; Routines for romio here
        .include "../io/6502_romio.asm"

NMI:
        NMI_MACRO

        ;--------------------------------------------------
        ; The romio write region has a small table here
        ;--------------------------------------------------
        .bank   second  (base=IOREGW, size=IOEND-IOREGW)
        .area   second  (ABS, BANK=second)
        .include "../io/romio_table.asm"

        ;--------------------------------------------------
        ; There is a little more room here, which is unused
        ;--------------------------------------------------
        .bank   third  (base=IOEND, size=VECTORS-IOEND)
        .area   third  (ABS, BANK=third)

        ;--------------------------------------------------
        ; Vector table
        ;--------------------------------------------------
        .bank   fourth  (base=VECTORS, size=ROMEND-VECTORS)
        .area   fourth  (ABS, BANK=fourth)        

        .dw     NMI
        .dw     STARTUP
        .dw     STARTUP

        .end
