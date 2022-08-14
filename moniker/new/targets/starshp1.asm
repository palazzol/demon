    .list   (me)

;--------------------------------------------------------------------------
; TARGET-SPECIFIC DEFINITIONS
;--------------------------------------------------------------------------
; RAM SETTINGS - usually in zero page
RAMSTRT .equ    0x00    ;start of ram, needs 7 bytes starting here
SSTACK	.equ	0xff	;start of stack, needs some memory below this address

;--------------------------------------------------------------------------
; NMI HANDLER
;--------------------------------------------------------------------------
        .macro  NMI_MACRO
        RTI
        .endm

;--------------------------------------------------------------------------
; STARTUP MACRO
;
; This are called once, and can be used do any target-specific
; initialization that is required
;--------------------------------------------------------------------------

        .macro  STARTUP_MACRO 
        sei              ; Disable interrupts - we don't handle them
        ldx     #SSTACK  ; hset up the stack
        txs
        cld              ; No Decimal
;       YOUR CODE CAN GO HERE
        .endm

;--------------------------------------------------------------------------
; EVERY MACRO
; This is called regularly, every polling loop, and can be used do any 
; target-specific task that is required, such as hitting a watchdog
;--------------------------------------------------------------------------

        .macro  EVERY_MACRO  
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
        .endm        

;--------------------------------------------------------------------------
; ROM TEMPLATE - this defines the rom layout, and which kind of io
;--------------------------------------------------------------------------
        .include "../rom_templates/6502_romio_f800_2k.asm"
