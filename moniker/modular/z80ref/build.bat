
..\tools\asz80.exe -o -p -s -l z80ref.asm
..\tools\aslink.exe -m -p -s z80ref.rel -u
..\tools\srec2bin -a 800 z80ref.s19 z80ref.bin
