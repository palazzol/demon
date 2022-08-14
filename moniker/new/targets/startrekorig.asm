    .list   (me)

;--------------------------------------------------------------------------
; TARGET-SPECIFIC DEFINITIONS
;--------------------------------------------------------------------------
; RAM SETTINGS
RAMADDR .equ    0xcff0      ; Start of RAM variables - need only 4 bytes here, but we have 16
                            ; Stack will grow towards 0 from this point

;--------------------------------------------------------------------------
; IRQ HANDLER
;--------------------------------------------------------------------------
        .macro  IRQ_MACRO
        RETI
        .endm
        
;--------------------------------------------------------------------------
; NMI HANDLER
;--------------------------------------------------------------------------
        .macro  NMI_MACRO
        RETN
        .endm

;--------------------------------------------------------------------------
; STARTUP MACROS
;
; These are called once, and can be used do any target-specific
; initialization that is required
;
; On the Z80, it is split into two.  This is because STARTUP1_MACRO is 
; usually place into a space-limited region.
; It's best to expand STARTUP2_MACRO and leave STARTUP1_MACRO alone.
;--------------------------------------------------------------------------

        .macro  STARTUP1_MACRO 
        DI                  ; Disable interrupts - we don't handle them
        LD      SP,RAMADDR  ; have to set valid SP
;       YOUR SMALL CODE CAN GO HERE
        .endm

        .macro  STARTUP2_MACRO 
        LD      A,0x81
        LD      HL,0xE000
        LD      (HL),A      ; blank the screen
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
        .include "../rom_templates/startrek_tether_0000_2k.asm"
