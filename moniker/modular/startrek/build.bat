
..\tools\asz80.exe -o -p -s -l startrek.asm
..\tools\aslink.exe -m -p -s startrek.rel -u
..\tools\srec2bin -a 800 startrek.s19 startrek.bin
..\tools\srec_cat.exe startrek.bin -binary -output startrek.hex -Intel -address-length=2 -output_block_size=16
