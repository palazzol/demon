SETSCL: ldaa    OUTBUF
        oraa    #0x01
        staa    OUTBUF
        adda    #>(IOREGW)
        staa    C
        ldaa    #<(IOREGW)
        staa    BREG
        ldx     BREG
        ldaa    0,X
        jsr     I2CDLY
        rts

CLRSCL: ldaa    OUTBUF
        anda    #0x1e
        staa    OUTBUF
        adda    #>(IOREGW)
        staa    C
        ldaa    #<(IOREGW)
        staa    BREG
        ldx     BREG
        ldaa    0,X
        rts

SETSDA: ldaa    OUTBUF
        anda    #0x1d
        staa    OUTBUF
        adda    #>(IOREGW)
        staa    C
        ldaa    #<(IOREGW)
        staa    BREG
        ldx     BREG
        ldaa    0,X
        jsr     I2CDLY
        rts

CLRSDA: ldaa    OUTBUF
        oraa    #0x02
        staa    OUTBUF
        adda    #>(IOREGW)
        staa    C
        ldaa    #<(IOREGW)
        staa    BREG
        ldx     BREG
        ldaa    0,X
        jsr     I2CDLY
        rts

READSDA:
        ldaa    OUTBUF
        adda    #>(IOREGR)
        staa    C
        ldaa    #<(IOREGR)
        staa    BREG
        ldx     BREG
        ldaa    0,X
        rora
        rts
                             