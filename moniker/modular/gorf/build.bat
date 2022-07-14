
..\tools\asz80.exe -o -l gorf.asm
..\tools\aslink.exe -u -s gorf.rel
..\tools\srec2bin -a 800 gorf.s19 ..\gorf.bin
