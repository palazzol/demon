
..\tools\asz80.exe -o -p -s -l startrek.asm
..\tools\aslink.exe -m -p -s startrek.rel -u
..\tools\srec2bin -a 800 startrek.s19 startrek.bin
