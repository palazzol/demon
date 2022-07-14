
tools\as6500.exe -o -p -s -l ref6502.asm
tools\aslink.exe -m -p -s ref6502.rel -u
tools\srec2bin -o f800 ref6502.s19 ref6502.bin
tools\srec_cat ref6502.bin -binary -output ref6502.hex -Intel -address-length=2 -output_block_size=16

tools\as6500.exe -o -p -s -l starshp1.asm
tools\aslink.exe -m -p -s starshp1.rel -u
tools\srec2bin -o f800 starshp1.s19 starshp1.bin
tools\srec_cat starshp1.bin -binary -output starshp1.hex -Intel -address-length=2 -output_block_size=16

