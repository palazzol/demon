

          
STRTADD .equ    0x0000      ; start of chip memory mapping
ROMSIZE .equ    0x0800      ; 2K ROM

        .include "../dd/dd.def"
        .include "../dd/z80.def"
        .include "../io/romio.def"

; TIMER SETTING
BIGDEL  .equ    0x0180      ; delay factor

        ;--------------------------------------------------
        ; On the Z80, the start address is 0x0000
        ; but the IRQ handler is at 0x0038
        ; So, we put a small but of startup code here,
        ; and then jump to after the NMI handler for more
        ;--------------------------------------------------
        .bank   first   (base=STRTADD, size=IRQADD-STRTADD)
        .area   first   (ABS, BANK=first)
STARTUP1:
        STARTUP1_MACRO
        JP      STARTUP2

        ;--------------------------------------------------
        ; This region is reserved for the IRQ handler
        ;--------------------------------------------------
        .bank   second  (base=IRQADD, size=NMIADD-IRQADD)
        .area   second  (ABS, BANK=second)
IRQ:
        IRQ_MACRO

        ;--------------------------------------------------
        ; This region starts with the NMI handler, and then
        ; continues with the rest of code immediately after
        ; It can go until the start of the romio region
        ;--------------------------------------------------
        .bank   third  (base=NMIADD, size=IOADD-NMIADD)
        .area   third  (ABS, BANK=third)
NMI:
        NMI_MACRO

STARTUP2:
        STARTUP2_MACRO

        ; Entry to main routine here
        .include "../dd/z80_main.asm"

EVERY:
        EVERY_MACRO

        ; Routines for romio here
        .include "../io/z80_romio.asm"

        ;--------------------------------------------------
        ; The romio region has a small table here
        ;--------------------------------------------------
        .bank   fourth  (base=IOADD, size=IOEND-IOADD)
        .area   fourth  (ABS, BANK=fourth)
        .include "../io/romio_table.asm"

        ;--------------------------------------------------
        ; There is a little more room here, which is unused
        ;--------------------------------------------------
        .bank   fifth  (base=IOEND, size=ROMEND-IOEND)
        .area   fifth  (ABS, BANK=fifth)

        .end
