REM This builds an image that replaces J2 on my Asteroids
tools\dasm.exe asteroids.asm -oasteroids.bin -lasteroids.lst -f3

tools\dasm.exe ref6502.asm -oref6502.bin -lref6502.lst -f3

tools\dasm.exe starshp1.asm -ostarshp1.bin -lstarshp1.lst -f3
