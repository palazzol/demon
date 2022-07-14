
        .include "settings.asm"
        
        ; This section must end before NMI Handler
        .bank   first   (base=STRTADD, size=NMIADD-STRTADD)
        .area   first   (ABS, BANK=first)

        .include "../z80/startup.asm"
        .include "irq.asm"

	; This section must end before the end of the chip
        .bank   second   (base=NMIADD, size=ENDADD-NMIADD)
        .area   second   (ABS, BANK=second)

        .include "../z80/nmi.asm"

        .include "../z80/romio.asm" 
        .include "loop.asm"

        .include "../z80/main.asm"

        .bank   third   (base=STRTADD+0x0500, size=0x100)
        .area   third   (ABS, BANK=third)
        
        .include "../z80/romiow.asm"
