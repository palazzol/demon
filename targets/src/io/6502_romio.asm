SETSCL: lda     OUTBUF
        ora     #0x01
        sta     OUTBUF
        tax
        lda     IOREGW,X
        jsr     I2CDLY
        rts

CLRSCL: lda     OUTBUF
        and     #0x1e
        sta     OUTBUF
        tax
        lda     IOREGW,X
        rts

SETSDA: lda     OUTBUF
        and     #0x1d
        sta     OUTBUF
        tax
        lda     IOREGW,X
        jsr     I2CDLY
        rts

CLRSDA: lda     OUTBUF
        ora     #0x02
        sta     OUTBUF
        tax
        lda     IOREGW,X
        jsr     I2CDLY
        rts

READSDA:
        ldx     OUTBUF
        lda     IOREGR,X
        ror
        rts
                             