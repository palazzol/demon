
..\tools\as6500.exe -o -p -s -l starshp1.asm
..\tools\aslink.exe -m -p -s starshp1.rel -u
..\tools\srec2bin -o f800 starshp1.s19 starshp1.bin
..\tools\srec_cat.exe starshp1.bin -binary -output starshp1.hex -Intel -address-length=2 -output_block_size=16
