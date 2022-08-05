
        .include "settings.asm"
        .include "../romio/defs.asm"

        ; This section must end before NMI Handler
        .bank   first   (base=STRTADD, size=NMIADD-STRTADD)
        .area   first   (ABS, BANK=first)

        .include "../z80/startup.asm"
        .include "irq.asm"

	; This section must end before the IO Region
        .bank   second   (base=NMIADD, size=IOADD-NMIADD)
        .area   second   (ABS, BANK=second)

        .include "../z80/nmi.asm"
        .include "../z80/romio.asm" 
        .include "loop.asm"
        .include "../z80/main.asm"
        
        .include "../romio/table.asm"
