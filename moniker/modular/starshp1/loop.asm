;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is called every time during the polling loop.  It can be
; used to run watchdog code, etc.  I have provided a simple delay loop
; so that the I2C slave is not overwhelmed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EVERY:
        ; reset the starshp1 watchdog
	lda     #0x01
	sta     0xdc06
	lda     #0xfe
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xcc00
	sta     0xdc06

        rts
