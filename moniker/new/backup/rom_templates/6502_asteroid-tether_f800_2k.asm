
         
STRTADD .equ    0xf800      ; start of chip memory mapping
ROMSIZE .equ    0x0800      ; 2K ROM 

        .include "../dd/dd.def"
        .include "../dd/6502.def"

; TIMER SETTING
BIGDEL  .equ    0x0180      ; delay factor

        .bank   first   (base=STRTADD, size=VECTORS)
        .area   first   (ABS, BANK=first)
STARTUP:
        STARTUP_MACRO

        ; Entry to main routine here
        .include "../dd/6502_main.asm"
        
EVERY:
        EVERY_MACRO

        ; Routines for tether io here
        .include "../io/asteroid-tether.asm"

NMI:
        NMI_MACRO

        ;--------------------------------------------------
        ; Vector table
        ;--------------------------------------------------
        .bank   second  (base=VECTORS, size=ROMEND-VECTORS)
        .area   second  (ABS, BANK=second)        

        .dw     NMI
        .dw     STARTUP
        .dw     STARTUP

        .end
