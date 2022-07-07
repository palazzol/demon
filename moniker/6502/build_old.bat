REM This builds an image that replaces J2 on my Asteroids
tools\dasm.exe moniker.asm -omoniker.bin -lmoniker.lst -f3
REM tools\dasm.exe ref6502_old.asm -oref6502_old.bin -lref6502_old.lst -f3
REM tools\dasm.exe starshp1_old.asm -ostarshp1_old.bin -lstarshp1_old.lst -f3

tools\as6500.exe -o -l ref6502_old.asm
tools\aslink.exe -s ref6502_old.rel
tools\srec2bin -o f800 ref6502_old.s19 ref6502_old.bin
tools\srec_cat ref6502_old.bin -binary -output ref6502_old.hex -Intel -address-length=2 -line-length=43

tools\as6500.exe -o -l starshp1_old.asm
tools\aslink.exe -s starshp1_old.rel
tools\srec2bin -o f800 starshp1_old.s19 starshp1_old.bin
tools\srec_cat starshp1_old.bin -binary -output starshp1_old.hex -Intel -address-length=2 -line-length=43
