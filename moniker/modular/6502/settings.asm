;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; You may need to adjust these variables for different targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RAM SETTINGS - usually in zero page

RAMSTRT .equ    0x00    ;start of ram, needs 7 bytes starting here
SSTACK	.equ	0xff	;start of stack, needs some memory below this address

; ROM SETTINGS - usually the last 2K of memory for 6502

STRTADD .equ    0xf800      ; start of chip memory mapping

; TIMER SETTING
BIGDEL  .equ    0x0180      ; delay factor

; I2C ADDRESSING
I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08

; VECTORS
VECTORS .equ    STRTADD+0x07fa




