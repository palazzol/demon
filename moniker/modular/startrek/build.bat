
..\tools\asz80.exe -o -l startrek.asm
..\tools\aslink.exe -u -s startrek.rel
..\tools\srec2bin -a 800 startrek.s19 ..\startrek.bin
