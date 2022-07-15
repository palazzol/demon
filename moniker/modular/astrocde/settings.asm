;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; You will need to adjust these variables for different targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RAM SETTINGS

RAMADDR .equ    0x4fce      ; Start of RAM variables - need only 4 bytes here, but we have 16

; ROM SETTINGS - usually the first 2K of memory for z80

STRTADD .equ    0x2000      ; start of chip memory mapping

; TIMER SETTING
BIGDEL  .equ    0x0180      ; delay factor

; I2C ADDRESSING
I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
