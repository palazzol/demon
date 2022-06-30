
        .org    IRQ1ADD

        PUSH    af
        ld      a,0x01
        ld      (0xdf01),A
        POP     af
        RETI
        
