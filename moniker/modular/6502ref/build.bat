
..\tools\as6500.exe -o -p -s -l 6502ref.asm
..\tools\aslink.exe -m -p -s 6502ref.rel -u
..\tools\srec2bin -o f800 6502ref.s19 6502ref.bin
..\tools\srec_cat.exe 6502ref.bin -binary -output 6502ref.hex -Intel -address-length=2 -output_block_size=16
