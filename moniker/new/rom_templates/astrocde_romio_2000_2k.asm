
         
STRTADD .equ    0x2000      ; start of chip memory mapping
ROMSIZE .equ    0x0800      ; 2K ROM 

        .include "../dd/dd.def"
        .include "../io/romio.def"

; TIMER SETTING
BIGDEL  .equ    0x0180      ; delay factor

        ;--------------------------------------------------
        ; On the Astrocade, the start address is 0x2000
        ;--------------------------------------------------
        .bank   first   (base=STRTADD, size=IOADD-STRTADD)
        .area   first   (ABS, BANK=first)

        .byte   0x55	    ; cartridge header
        .word   0x0218	    ; next menu item (first one)
        .word   TITLE	    ; title pointer
        .word   STARTUP1	; start pointer
        
        ret		    ; rst8
        nop
        nop

        ret		    ; rst16
        nop
        nop
        
        ret		    ; rst24
        nop
        nop
        
        ret		    ; rst32
        nop
        nop
        
        ret		    ; rst40
        nop
        nop
        
        ret		    ; rst48
        nop
        nop

TITLE:	
        MESSAGE_MACRO
    	
STARTUP1:  
        STARTUP1_MACRO

        ; Entry to main routine here
        .include "../dd/z80_main.asm"

        ; Routines for romio here
        .include "../io/z80_romio.asm"

EVERY:
        EVERY_MACRO

        ;--------------------------------------------------
        ; The romio write region has a small table here
        ;--------------------------------------------------
        .bank   second  (base=IOREGW, size=IOEND-IOREGW)
        .area   second  (ABS, BANK=second)
        .include "../io/romio_table.asm"

        ;--------------------------------------------------
        ; There is a little more room here, which is unused
        ;--------------------------------------------------
        .bank   third  (base=IOREGW+0x20, size=ROMEND-IOEND)
        .area   third  (ABS, BANK=third)

        .end
