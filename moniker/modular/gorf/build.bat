
..\tools\asz80.exe -o -p -s -l gorf.asm
..\tools\aslink.exe -m -p -s gorf.rel -u
..\tools\srec2bin -a 800 gorf.s19 gorf.bin
