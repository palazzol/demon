    .list   (me)

;--------------------------------------------------------------------------
; TARGET-SPECIFIC DEFINITIONS
;--------------------------------------------------------------------------
; RAM SETTINGS
RAMADDR .equ    0x77f0      ; Start of RAM variables - need only 4 bytes here, but we have 16
                            ; Stack will grow towards 0 from this point

;--------------------------------------------------------------------------
; MESSAGE MACRO
;--------------------------------------------------------------------------
        .macro  MESSAGE_MACRO
    	.asciz  "BY: EVAN&FRANK/DEMON DEBUGGER/2019"
        .endm

;--------------------------------------------------------------------------
; STARTUP MACROS
;
; These are called once, and can be used do any target-specific
; initialization that is required
;--------------------------------------------------------------------------

        .macro  STARTUP1_MACRO 
        DI                  ; Disable interrupts - we don't handle them
        LD      SP,RAMADDR  ; have to set valid SP
;       YOUR SMALL CODE CAN GO HERE
        .endm     

;--------------------------------------------------------------------------
; EVERY MACRO
; This is called regularly, every polling loop, and can be used do any 
; target-specific task that is required, such as hitting a watchdog
;--------------------------------------------------------------------------

        .macro  EVERY_MACRO  
;       YOUR CODE CAN GO HERE
        RET
        .endm        

;--------------------------------------------------------------------------
; ROM TEMPLATE - this defines the rom layout, and which kind of io
;--------------------------------------------------------------------------
        .include "../rom_templates/coleco-cart_romio_8000_2k.asm"
