
        .include "../6502/settings.asm"
        .include "../romio/defs.asm"

        ; This section must end before the IO Region
        .bank   first   (base=STRTADD, size=IOADD-STRTADD)
        .area   first   (ABS, BANK=first)

        .include "../6502/startup.asm"
        .include "../6502/loop.asm"
        .include "../6502/nmi.asm"
        .include "../6502/romio.asm" 
        .include "../6502/main.asm"

        .include "../romio/table.asm"

        .include "../6502/vectors.asm"
