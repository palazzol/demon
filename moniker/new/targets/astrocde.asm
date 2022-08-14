    .list   (me)

;--------------------------------------------------------------------------
; TARGET-SPECIFIC DEFINITIONS
;--------------------------------------------------------------------------
; RAM SETTINGS
RAMADDR .equ    0x4fce      ; Start of RAM variables - need only 4 bytes here, but we have 16
                            ; Stack will grow towards 0 from this point

;--------------------------------------------------------------------------
; MESSAGE MACRO
;--------------------------------------------------------------------------
        .macro  MESSAGE_MACRO
        .ascii	"DEMON DEBUGGER"
        .byte	0x00
        .endm

;--------------------------------------------------------------------------
; STARTUP MACROS
;
; These are called once, and can be used do any target-specific
; initialization that is required
;--------------------------------------------------------------------------

        .macro  STARTUP1_MACRO 
        ; We are relying on the console to do this initialization 
        ;DI
        ;LD      SP,RAMADDR   ; have to set valid SP
        .endm     

;--------------------------------------------------------------------------
; EVERY MACRO
; This is called regularly, every polling loop, and can be used do any 
; target-specific task that is required, such as hitting a watchdog
;--------------------------------------------------------------------------

        .macro  EVERY_MACRO  
        IN	A,(0x10)    ; hit watchdog
        RET
        .endm        

;--------------------------------------------------------------------------
; ROM TEMPLATE - this defines the rom layout, and which kind of io
;--------------------------------------------------------------------------
        .include "../rom_templates/astrocde-cart_romio_2000_2k.asm"
