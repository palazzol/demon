
..\tools\as6500.exe -o -p -s -l asteroidorig.asm
..\tools\aslink.exe -m -p -s asteroidorig.rel -u
..\tools\srec2bin -o f800 asteroidorig.s19 asteroidorig.bin
..\tools\srec_cat.exe asteroidorig.bin -binary -output asteroidorig.hex -Intel -address-length=2 -output_block_size=16
