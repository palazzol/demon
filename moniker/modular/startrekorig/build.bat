
..\tools\asz80.exe -o -l startrekorig.asm
..\tools\aslink.exe -u -s startrekorig.rel
..\tools\srec2bin -a 800 startrekorig.s19 ..\startrekorig.bin
