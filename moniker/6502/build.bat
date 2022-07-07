
tools\as6500.exe -o -l ref6502.asm
tools\aslink.exe -s ref6502.rel
tools\srec2bin -o f800 ref6502.s19 ref6502.bin
tools\srec_cat ref6502.bin -binary -output ref6502.hex -Intel -address-length=2 -line-length=43

tools\as6500.exe -o -l starshp1.asm
tools\aslink.exe -s starshp1.rel
tools\srec2bin -o f800 starshp1.s19 starshp1.bin
tools\srec_cat starshp1.bin -binary -output starshp1.hex -Intel -address-length=2 -line-length=43

