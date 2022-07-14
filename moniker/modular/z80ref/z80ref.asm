
        .include "../z80/settings.asm"
        .include "../z80/romio_defs.asm"

        ; This section must end before NMI Handler
        .bank   first   (base=STRTADD, size=NMIADD-STRTADD)
        .area   first   (ABS, BANK=first)

        .include "../z80/startup.asm" 

	; This section must end before the IO Region
        .bank   second   (base=NMIADD, size=IOADD-NMIADD)
        .area   second   (ABS, BANK=second)

        .include "../z80/nmi.asm"
        .include "../z80/romio.asm" 
        .include "../z80/loop.asm"
        .include "../z80/main.asm"

        .bank   third   (base=IOREGW, size=0x20)
        .area   third   (ABS, BANK=third)
        
        .include "../z80/romio_table.asm"

