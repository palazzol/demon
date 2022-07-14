
..\tools\asz80.exe -o -p -s -l startrekorig.asm
..\tools\aslink.exe -m -p -s startrekorig.rel -u
..\tools\srec2bin -a 800 startrekorig.s19 startrekorig.bin
..\tools\srec_cat.exe startrekorig.bin -binary -output startrekorig.hex -Intel -address-length=2 -output_block_size=16

