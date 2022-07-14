
        .include "settings.asm"

        ; This section must end before NMI Handler
        .bank   first   (base=STRTADD, size=NMIADD-STRTADD)
        .area   first   (ABS, BANK=first)

        .include "startup.asm" 

	; This section must end before the end of the chip
        .bank   second   (base=NMIADD, size=ENDADD-NMIADD)
        .area   second   (ABS, BANK=second)

        .include "../z80/nmi.asm"
        .include "io.asm" 
        .include "../z80/loop.asm"
        .include "../z80/main.asm"
