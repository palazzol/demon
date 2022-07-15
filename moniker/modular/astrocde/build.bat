
..\tools\asz80.exe -o -p -s -l astrocde.asm
..\tools\aslink.exe -m -p -s astrocde.rel -u
..\tools\srec2bin -o 2000 -a 800 astrocde.s19 astrocde.bin
..\tools\srec_cat.exe astrocde.bin -binary -output astrocde.hex -Intel -address-length=2 -output_block_size=16
