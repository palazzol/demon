
tools\asz80.exe -o -l moniker.asm
tools\aslink.exe -s moniker.rel
tools\srec2bin moniker.s19 moniker.bin

tools\asz80.exe -o -l bit90.asm
tools\aslink.exe -s bit90.rel
tools\srec2bin -o 8000 bit90.s19 bit90.bin

tools\asz80.exe -o -l sraider.asm
tools\aslink.exe -s sraider.rel
tools\srec2bin sraider.s19 sraider.bin

tools\asz80.exe -o -l gorf.asm
tools\aslink.exe -s gorf.rel
tools\srec2bin gorf.s19 gorf.bin

tools\asz80.exe -o -l astrocade.asm
tools\aslink.exe -s astrocade.rel
tools\srec2bin -o 2000 astrocade.s19 astrocade.bin

tools\asz80.exe -o -l refz80.asm
tools\aslink.exe -s refz80.rel
tools\srec2bin -a 800 refz80.s19 refz80.bin

tools\asz80.exe -o -l startrek.asm
tools\aslink.exe -s startrek.rel
tools\srec2bin -a 800 startrek.s19 startrek.bin
