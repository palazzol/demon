        .byte   0x55	    ; cartridge header
        .word   0x0218	    ; next menu item (first one)
        .word   TITLE	    ; title pointer
        .word   START	    ; start pointer
        
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

TITLE:	.ascii	"DEMON DEBUGGER"
        .byte	0x00
