
tools\asz80.exe -o -p -s -l moniker.asm
tools\aslink.exe -m -p -s moniker.rel -u
tools\srec2bin moniker.s19 moniker.bin

tools\asz80.exe -o -p -s -l bit90.asm
tools\aslink.exe -m -p -s bit90.rel -u
tools\srec2bin -o 8000 bit90.s19 bit90.bin

tools\asz80.exe -o -p -s -l sraider.asm
tools\aslink.exe -m -p -s sraider.rel -u
tools\srec2bin sraider.s19 sraider.bin

tools\asz80.exe -o -p -s -l sraider2.asm
tools\aslink.exe -m -p -s sraider2.rel -u
tools\srec2bin sraider2.s19 sraider2.bin

tools\asz80.exe -o -p -s -l gorf.asm
tools\aslink.exe -m -p -s gorf.rel -u
tools\srec2bin gorf.s19 gorf.bin
