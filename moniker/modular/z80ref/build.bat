
..\tools\asz80.exe -o -p -s -l z80ref.asm
..\tools\aslink.exe -m -p -s z80ref.rel -u
..\tools\srec2bin -a 800 z80ref.s19 z80ref.bin
..\tools\srec_cat.exe z80ref.bin -binary -output z80ref.hex -Intel -address-length=2 -output_block_size=16
