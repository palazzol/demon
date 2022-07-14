;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; You will need to adjust these variables for different targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RAM SETTINGS

RAMADDR .equ    0xdff0      ; Start of RAM variables - need only 4 bytes here, but we have 16
                            ; Stack will grow towards 0 from this point

; ROM SETTINGS - usually the first 2K of memory for z80

STRTADD .equ    0x0000      ; start of chip memory mapping
IRQ1ADD .equ    0x0038      ; IRQ
NMIADD  .equ    0x0066      ; location of NMI handler
ENDADD  .equ    0x0800      ; end of chip memory mapping (+1)

; TIMER SETTING
BIGDEL  .equ    0x0180      ;delay factor

; I2C ADDRESSING
I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08