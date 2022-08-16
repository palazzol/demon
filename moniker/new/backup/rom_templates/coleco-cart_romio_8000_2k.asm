
          
STRTADD .equ    0x8000      ; start of chip memory mapping
ROMSIZE .equ    0x0800      ; 2K ROM

        .include "../dd/dd.def"
        .include "../io/romio.def"

; TIMER SETTING
BIGDEL  .equ    0x0180      ; delay factor

        ;--------------------------------------------------
        ; On the ColecoVision, the start address is 0x8000
        ;--------------------------------------------------
        .bank   first   (base=STRTADD, size=IOADD-STRTADD)
        .area   first   (ABS, BANK=first)

        .db	0xaa	    ; cartridge signature
    	.db	0x55
    	
    	.dw     0x0000
    	.dw     0x0000
    	.dw     0x0000
    	.dw     0x0000
    	.dw     STARTUP1
    	JP      0x0008
    	JP      0x0010
    	JP      0x0018
    	JP      0x0020
    	JP      0x0028
    	JP      0x0030
    	JP      0x0038
    	JP      0x0066
    	
        MESSAGE_MACRO
    	
STARTUP1:  
        STARTUP1_MACRO

        ; Entry to main routine here
        .include "../dd/z80_main.asm"

EVERY:
        EVERY_MACRO

        ; Routines for romio here
        .include "../io/z80_romio.asm"

        ;--------------------------------------------------
        ; The romio region has a small table here
        ;--------------------------------------------------
        .bank   second  (base=IOADD, size=IOEND-IOADD)
        .area   second  (ABS, BANK=second)
        .include "../io/romio_table.asm"

        ;--------------------------------------------------
        ; There is a little more room here, which is unused
        ;--------------------------------------------------
        .bank   third  (base=IOREGW+0x20, size=ROMEND-IOEND)
        .area   third  (ABS, BANK=third)

        .end
