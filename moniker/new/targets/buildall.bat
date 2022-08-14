

..\tools\asz80.exe -o -p -s -l z80ref.asm
..\tools\aslink.exe -m -p -s z80ref.rel -u
..\tools\srec2bin -o 0000 -a 800 -f ff z80ref.s19 z80ref.bin
..\tools\srec_cat.exe z80ref.bin -binary -output z80ref.hex -Intel -address-length=2 -output_block_size=16

..\tools\asz80.exe -o -p -s -l startrek.asm
..\tools\aslink.exe -m -p -s startrek.rel -u
..\tools\srec2bin -o 0000 -a 800 -f ff startrek.s19 startrek.bin
..\tools\srec_cat.exe startrek.bin -binary -output startrek.hex -Intel -address-length=2 -output_block_size=16

..\tools\asz80.exe -o -p -s -l startrekorig.asm
..\tools\aslink.exe -m -p -s startrekorig.rel -u
..\tools\srec2bin -o 0000 -a 800 -f ff startrekorig.s19 startrekorig.bin
..\tools\srec_cat.exe startrekorig.bin -binary -output startrekorig.hex -Intel -address-length=2 -output_block_size=16

..\tools\asz80.exe -o -p -s -l coleco.asm
..\tools\aslink.exe -m -p -s coleco.rel -u
..\tools\srec2bin -o 8000 -a 800 -f ff coleco.s19 coleco.bin
..\tools\srec_cat.exe coleco.bin -binary -output coleco.hex -Intel -address-length=2 -output_block_size=16

..\tools\asz80.exe -o -p -s -l astrocde.asm
..\tools\aslink.exe -m -p -s astrocde.rel -u
..\tools\srec2bin -o 2000 -a 800 -f ff astrocde.s19 astrocde.bin
..\tools\srec_cat.exe astrocde.bin -binary -output astrocde.hex -Intel -address-length=2 -output_block_size=16

..\tools\asz80.exe -o -p -s -l gorf.asm
..\tools\aslink.exe -m -p -s gorf.rel -u
..\tools\srec2bin -o 0000 -a 800 -f ff gorf.s19 gorf.bin
..\tools\srec_cat.exe gorf.bin -binary -output gorf.hex -Intel -address-length=2 -output_block_size=16

..\tools\asz80.exe -o -p -s -l sraider.asm
..\tools\aslink.exe -m -p -s sraider.rel -u
..\tools\srec2bin -o 0000 -a 800 -f ff sraider.s19 sraider.bin
..\tools\srec_cat.exe sraider.bin -binary -output sraider.hex -Intel -address-length=2 -output_block_size=16

..\tools\as6500.exe -o -p -s -l 6502ref.asm
..\tools\aslink.exe -m -p -s 6502ref.rel -u
..\tools\srec2bin -o f800 -a 800 -f ff 6502ref.s19 6502ref.bin
..\tools\srec_cat.exe 6502ref.bin -binary -output 6502ref.hex -Intel -address-length=2 -output_block_size=16

..\tools\as6500.exe -o -p -s -l starshp1.asm
..\tools\aslink.exe -m -p -s starshp1.rel -u
..\tools\srec2bin -o f800 -a 800 -f ff starshp1.s19 starshp1.bin
..\tools\srec_cat.exe starshp1.bin -binary -output starshp1.hex -Intel -address-length=2 -output_block_size=16

..\tools\as6500.exe -o -p -s -l asteroidorig.asm
..\tools\aslink.exe -m -p -s asteroidorig.rel -u
..\tools\srec2bin -o f800 -a 800 -f ff asteroidorig.s19 asteroidorig.bin
..\tools\srec_cat.exe asteroidorig.bin -binary -output asteroidorig.hex -Intel -address-length=2 -output_block_size=16



