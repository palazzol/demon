
..\tools\asz80.exe -o -p -s -l sraider2.asm
..\tools\aslink.exe -m -p -s sraider2.rel -u
..\tools\srec2bin -a 800 sraider2.s19 sraider2.bin
..\tools\srec_cat.exe sraider2.bin -binary -output sraider2.hex -Intel -address-length=2 -output_block_size=16
