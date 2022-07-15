
..\tools\asz80.exe -o -p -s -l bit90.asm
..\tools\aslink.exe -m -p -s bit90.rel -u
..\tools\srec2bin -o 8000 -a 800 bit90.s19 bit90.bin
..\tools\srec_cat.exe bit90.bin -binary -output bit90.hex -Intel -address-length=2 -output_block_size=16
