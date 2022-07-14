REM This builds an image that replaces J2 on my Asteroids
tools\dasm.exe moniker.asm -omoniker.bin -lmoniker.lst -f3
tools\srec_cat.exe moniker.bin -binary -output moniker.hex -Intel -address-length=2 -output_block_size=16

tools\as6500.exe -o -p -s -l ref6502_old.asm
tools\aslink.exe -m -p -s ref6502_old.rel -u
tools\srec2bin -o f800 ref6502_old.s19 ref6502_old.bin
tools\srec_cat ref6502_old.bin -binary -output ref6502_old.hex -Intel -address-length=2 -output_block_size=16

tools\as6500.exe -o -p -s -l starshp1_old.asm
tools\aslink.exe -m -p -s starshp1_old.rel -u
tools\srec2bin -o f800 starshp1_old.s19 starshp1_old.bin
tools\srec_cat starshp1_old.bin -binary -output starshp1_old.hex -Intel -address-length=2 -output_block_size=16
