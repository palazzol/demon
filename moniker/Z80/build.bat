
tools\asz80.exe -o -p -s -l moniker.asm
tools\aslink.exe -m -p -s moniker.rel -u
tools\srec2bin -a 800 moniker.s19 moniker.bin

tools\asz80.exe -o -p -s -l bit90.asm
tools\aslink.exe -m -p -s bit90.rel -u
tools\srec2bin -o 8000 -a 800 bit90.s19 bit90.bin

tools\asz80.exe -o -p -s -l sraider.asm
tools\aslink.exe -m -p -s sraider.rel -u
tools\srec2bin -a 800 sraider.s19 sraider.bin

tools\asz80.exe -o -p -s -l sraider2.asm
tools\aslink.exe -m -p -s sraider2.rel -u
tools\srec2bin -a 800 sraider2.s19 sraider2.bin

tools\asz80.exe -o -p -s -l gorf.asm
tools\aslink.exe -m -p -s gorf.rel -u
tools\srec2bin -a 800 gorf.s19 gorf.bin

tools\asz80.exe -o -p -s -l astrocade.asm
tools\aslink.exe -m -p -s astrocade.rel -u
tools\srec2bin -o 2000 -a 800 astrocade.s19 astrocade.bin

tools\asz80.exe -o -p -s -l refz80.asm
tools\aslink.exe -m -p -s refz80.rel -u
tools\srec2bin -a 800 refz80.s19 refz80.bin

tools\asz80.exe -o -p -s -l startrek.asm
tools\aslink.exe -m -p -s startrek.rel -u
tools\srec2bin -a 800 startrek.s19 startrek.bin