
tools\asz80.exe -o -l sraider2.asm
tools\aslink.exe -s sraider2.rel -u
tools\srec2bin -a 800 sraider2.s19 sraider2.bin
