
        .include "settings.asm"
        .include "../z80/romio_defs.asm"

        ; This section must end before the IO Region
        .bank   first   (base=STRTADD, size=IOADD-STRTADD)
        .area   first   (ABS, BANK=first)

        .include "cartheader.asm" 

        .include "../z80/romio.asm" 
        .include "mainloop.asm"

        .bank   second   (base=IOREGW, size=0x20)
        .area   second   (ABS, BANK=second)
        
        .include "../z80/romio_table.asm"

