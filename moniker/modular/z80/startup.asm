
START:  DI                  ; Disable interrupts - we don't handle them
        JP      INIT        ; go to initialization code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is called once, and should be used do any game-specific
; initialization that is required
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ONCE:   
;       YOUR CODE CAN GO HERE
        RET
