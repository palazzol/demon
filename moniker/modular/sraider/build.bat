
..\tools\asz80.exe -o -p -s -l sraider.asm
..\tools\aslink.exe -m -p -s sraider.rel -u
..\tools\srec2bin -a 800 sraider.s19 sraider.bin
..\tools\srec_cat.exe sraider.bin -binary -output sraider.hex -Intel -address-length=2 -output_block_size=16
