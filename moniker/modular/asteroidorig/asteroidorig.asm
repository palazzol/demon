
; This code replaces ROM J2 on my Asteroids

        .include "../6502/settings.asm"

        .bank   first   (base=STRTADD, size=VECTORS-STRTADD)
        .area   first   (ABS, BANK=first)

        .include "../6502/nmi.asm"
        .include "../6502/startup.asm"
        .include "../6502/loop.asm"
        .include "io.asm"
        .include "../6502/main.asm"

        .include "../6502/vectors.asm"
