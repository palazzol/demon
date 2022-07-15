
tools\asz80.exe -o -p -s -l moniker.asm
tools\aslink.exe -m -p -s moniker.rel -u
tools\srec2bin -a 800 moniker.s19 moniker.bin
tools\srec_cat.exe moniker.bin -binary -output moniker.hex -Intel -address-length=2 -output_block_size=16

tools\asz80.exe -o -p -s -l bit90.asm
tools\aslink.exe -m -p -s bit90.rel -u
tools\srec2bin -o 8000 -a 800 bit90.s19 bit90.bin
tools\srec_cat.exe bit90.bin -binary -output bit90.hex -Intel -address-length=2 -output_block_size=16

tools\asz80.exe -o -p -s -l sraider.asm
tools\aslink.exe -m -p -s sraider.rel -u
tools\srec2bin -a 800 sraider.s19 sraider.bin
tools\srec_cat.exe sraider.bin -binary -output sraider.hex -Intel -address-length=2 -output_block_size=16

tools\asz80.exe -o -p -s -l sraider2.asm
tools\aslink.exe -m -p -s sraider2.rel -u
tools\srec2bin -a 800 sraider2.s19 sraider2.bin
tools\srec_cat.exe sraider2.bin -binary -output sraider2.hex -Intel -address-length=2 -output_block_size=16

tools\asz80.exe -o -p -s -l gorf.asm
tools\aslink.exe -m -p -s gorf.rel -u
tools\srec2bin -a 800 gorf.s19 gorf.bin
tools\srec_cat.exe gorf.bin -binary -output gorf.hex -Intel -address-length=2 -output_block_size=16

tools\asz80.exe -o -p -s -l astrocde.asm
tools\aslink.exe -m -p -s astrocde.rel -u
tools\srec2bin -o 2000 -a 800 astrocde.s19 astrocde.bin
tools\srec_cat.exe astrocde.bin -binary -output astrocde.hex -Intel -address-length=2 -output_block_size=16

tools\asz80.exe -o -p -s -l refz80.asm
tools\aslink.exe -m -p -s refz80.rel -u
tools\srec2bin -a 800 refz80.s19 refz80.bin
tools\srec_cat.exe refz80.bin -binary -output refz80.hex -Intel -address-length=2 -output_block_size=16

tools\asz80.exe -o -p -s -l startrek.asm
tools\aslink.exe -m -p -s startrek.rel -u
tools\srec2bin -a 800 startrek.s19 startrek.bin
tools\srec_cat.exe startrek.bin -binary -output startrek.hex -Intel -address-length=2 -output_block_size=16
