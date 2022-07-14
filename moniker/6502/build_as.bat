
tools\as6500.exe -o -l ref6502_as.asm
tools\aslink.exe -s ref6502_as.rel
tools\srec2bin -o f800 ref6502_as.s19 ref6502_as.bin
