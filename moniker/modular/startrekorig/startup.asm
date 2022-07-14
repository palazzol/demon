
START:  DI                  ; Disable interrupts - we don't handle them
        JP      INIT        ; go to initialization code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is called once, and should be used do any game-specific
; initialization that is required
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ONCE:   
        LD      A,0x81
        LD      HL,0xE000
        LD      (HL),A      ; blank the screen
        RET
