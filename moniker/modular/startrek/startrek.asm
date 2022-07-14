
        .include "settings.asm"

        ; This section must end before NMI Handler
        .bank   first   (base=STRTADD, size=NMIADD-STRTADD)
        .area   first   (ABS, BANK=first)

        .include "../startrekorig/startup.asm" 
        .include "../z80/romio.asm" 
        .include "../z80/loop.asm"

	; This section must end before IO Region
        .bank   second   (base=NMIADD, size=IOREG-NMIADD)
        .area   second   (ABS, BANK=second)

        .include "../z80/nmi.asm"
        .include "../z80/main.asm"
