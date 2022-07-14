
..\tools\asz80.exe -o -l z80ref.asm
..\tools\aslink.exe -u -s z80ref.rel
..\tools\srec2bin -a 800 z80ref.s19 ..\z80ref.bin
