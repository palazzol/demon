                              1 ;
                              2 ; Moniker - Z80 Version
                              3 ; by Frank Palazzolo
                              4 ; For Space Raider - CPU2
                              5 ;
                              6         .area   CODE1   (ABS)   ; ASXXXX directive, absolute addressing
                              7 
                     2000     8 DATAIN	.equ	0x2000		; where to read data in from
                              9 
                     63F0    10 CMDBUF  .equ    0x63f0      ; Need only 4 bytes of ram for command buffer
                             11                             ; (We will save 12 more just in case)
                     63F0    12 SSTACK  .equ    0x63f0      ; Start of stack
                             13 
                     0011    14 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    15 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                             16 
                     0180    17 BIGDEL  .equ    0x0180      ; bigger delay, for now still fairly small
                             18 
   0000                      19         .org    0x0000
                             20     
   0000 F3            [ 4]   21 START:  DI                  ; Disable interrupts - we don't handle them
   0001 C3 39 01      [10]   22         JP      INIT        ; go to initialization code
                             23     
                             24 ; Set the SCL pin high
                             25 ; D is the global buffer
                             26 ; Destroys A
   0004                      27 SETSCL:
   0004 7A            [ 4]   28         LD      A,D
   0005 F6 01         [ 7]   29         OR      0x01
   0007 57            [ 4]   30         LD      D,A
   0008 E5            [11]   31         PUSH    HL
   0009 26 40         [ 7]   32         LD      H,0x40
   000B 6F            [ 4]   33         LD      L,A
   000C 7E            [ 7]   34         LD      A,(HL)
   000D E1            [10]   35         POP     HL
   000E CD 43 00      [17]   36         CALL    I2CDELAY
   0011 C9            [10]   37         RET
                             38     
                             39 ; Set the SCL pin low
                             40 ; D is the global buffer
                             41 ; Destroys A
   0012                      42 CLRSCL:
   0012 7A            [ 4]   43         LD      A,D
   0013 E6 FE         [ 7]   44         AND     0xfe
   0015 57            [ 4]   45         LD      D,A
   0016 E5            [11]   46         PUSH    HL
   0017 26 40         [ 7]   47         LD      H,0x40
   0019 6F            [ 4]   48         LD      L,A
   001A 7E            [ 7]   49         LD      A,(HL)
   001B E1            [10]   50         POP     HL
   001C CD 43 00      [17]   51         CALL    I2CDELAY
   001F C9            [10]   52         RET
                             53 
                             54 ; Set the DOUT pin low
                             55 ; D is the global buffer
                             56 ; Destroys A 
   0020                      57 SETSDA:
   0020 7A            [ 4]   58         LD      A,D
   0021 E6 FD         [ 7]   59         AND     0xfd
   0023 57            [ 4]   60         LD      D,A
   0024 E5            [11]   61         PUSH    HL
   0025 26 40         [ 7]   62         LD      H,0x40
   0027 6F            [ 4]   63         LD      L,A
   0028 7E            [ 7]   64         LD      A,(HL)
   0029 E1            [10]   65         POP     HL
   002A CD 43 00      [17]   66         CALL    I2CDELAY
   002D C9            [10]   67         RET
                             68 
                             69 ; Set the DOUT pin high
                             70 ; D is the global buffer
                             71 ; Destroys A  
   002E                      72 CLRSDA:
   002E 7A            [ 4]   73         LD      A,D
   002F F6 02         [ 7]   74         OR      0x02
   0031 57            [ 4]   75         LD      D,A
   0032 E5            [11]   76         PUSH    HL
   0033 26 40         [ 7]   77         LD      H,0x40
   0035 6F            [ 4]   78         LD      L,A
   0036 7E            [ 7]   79         LD      A,(HL)
   0037 E1            [10]   80         POP     HL
   0038 CD 43 00      [17]   81         CALL    I2CDELAY
   003B C9            [10]   82         RET
                             83 
                             84 ; Read the DIN pin 
                             85 ; returns bit in carry flag    
   003C                      86 READSDA:
   003C 21 00 20      [10]   87         LD      HL,DATAIN
   003F 7E            [ 7]   88         LD      A,(HL)      ;perform a read into bit0
   0040 CB 3F         [ 8]   89         SRL     A           ;carry flag
   0042 C9            [10]   90         RET
                             91     
                             92 ; Delay for half a bit time
   0043                      93 I2CDELAY:
   0043 C9            [10]   94         RET     ; This is plenty
                             95 
                             96 ; I2C Start Condition
                             97 ; Uses HL
                             98 ; Destroys A
   0044                      99 I2CSTART:
   0044 CD 2E 00      [17]  100         CALL    CLRSDA      
   0047 CD 12 00      [17]  101         CALL    CLRSCL
   004A C9            [10]  102         RET
                            103 
                            104 ; I2C Stop Condition
                            105 ; Uses HL
                            106 ; Destroys A
   004B                     107 I2CSTOP:
   004B CD 2E 00      [17]  108         CALL    CLRSDA
   004E CD 04 00      [17]  109         CALL    SETSCL
   0051 CD 20 00      [17]  110         CALL    SETSDA
   0054 C9            [10]  111         RET
                            112 
                            113 ; I2C Read Bit routine
                            114 ; Returns bit in carry blag
                            115 ; Destroys A
   0055                     116 I2CRBIT:
   0055 CD 20 00      [17]  117         CALL    SETSDA
   0058 CD 04 00      [17]  118         CALL    SETSCL
   005B CD 3C 00      [17]  119         CALL    READSDA
   005E F5            [11]  120         PUSH    AF          ; save carry flag
   005F CD 12 00      [17]  121         CALL    CLRSCL
   0062 F1            [10]  122         POP     AF          ; rv in carry flag
   0063 C9            [10]  123         RET
                            124 
                            125         ; Make sure this code ends before address 0x66 !
                            126         
   0066                     127         .org    0x0066
   0066 C3 00 00      [10]  128 NMI:    JP      START       ; restart on NMI
                            129 
                            130 ; I2C Write Bit routine
                            131 ; Takes carry flag
                            132 ; Destroys A
   0069                     133 I2CWBIT:
   0069 30 05         [12]  134         JR      NC,DOCLR
   006B CD 20 00      [17]  135         CALL    SETSDA
   006E 18 03         [12]  136         JR      AHEAD
   0070                     137 DOCLR:
   0070 CD 2E 00      [17]  138         CALL    CLRSDA
   0073                     139 AHEAD:
   0073 CD 04 00      [17]  140         CALL    SETSCL
   0076 CD 12 00      [17]  141         CALL    CLRSCL
   0079 C9            [10]  142         RET
                            143 
                            144 ; I2C Write Byte routine
                            145 ; Takes A
                            146 ; Destroys B
                            147 ; Returns carry bit
   007A                     148 I2CWBYTE:
   007A 06 08         [ 7]  149         LD      B,8
   007C                     150 ILOOP:
   007C C5            [11]  151         PUSH    BC          ; save B
   007D CB 07         [ 8]  152         RLC     A    
   007F F5            [11]  153         PUSH    AF          ; save A
   0080 CD 69 00      [17]  154         CALL    I2CWBIT
   0083 F1            [10]  155         POP     AF
   0084 C1            [10]  156         POP     BC
   0085 10 F5         [13]  157         DJNZ    ILOOP
   0087 CD 55 00      [17]  158         CALL    I2CRBIT
   008A C9            [10]  159         RET
                            160 
                            161 ; I2C Read Byte routine
                            162 ; Destroys BC
                            163 ; Returns A
   008B                     164 I2CRBYTE:
   008B 06 08         [ 7]  165         LD      B,8
   008D 0E 00         [ 7]  166         LD      C,0
   008F                     167 LOOP3:
   008F C5            [11]  168         PUSH    BC
   0090 CD 55 00      [17]  169         CALL    I2CRBIT     ; get bit in carry flag
   0093 C1            [10]  170         POP     BC
   0094 CB 11         [ 8]  171         RL      C           ; rotate carry into bit0 of C register
   0096 10 F7         [13]  172         DJNZ    LOOP3
   0098 AF            [ 4]  173         XOR     A           ; clear carry flag              
   0099 C5            [11]  174         PUSH    BC
   009A CD 69 00      [17]  175         CALL    I2CWBIT
   009D C1            [10]  176         POP     BC
   009E 79            [ 4]  177         LD      A,C
   009F C9            [10]  178         RET
                            179 ;
                            180 
                            181 ; Read 4-byte I2C Command from device into CMDBUF
                            182 ; Uses HL
                            183 ; Destroys A,BC,HL
   00A0                     184 I2CRREQ:
   00A0 CD 44 00      [17]  185         CALL    I2CSTART
   00A3 3E 11         [ 7]  186         LD      A,I2CRADR
   00A5 CD 7A 00      [17]  187         CALL    I2CWBYTE
   00A8 38 1A         [12]  188         JR      C,SKIP
   00AA CD 8B 00      [17]  189         CALL    I2CRBYTE
   00AD DD 77 00      [19]  190         LD      (IX),A
   00B0 CD 8B 00      [17]  191         CALL    I2CRBYTE
   00B3 DD 77 01      [19]  192         LD      (IX+1),A  
   00B6 CD 8B 00      [17]  193         CALL    I2CRBYTE
   00B9 DD 77 02      [19]  194         LD      (IX+2),A
   00BC CD 8B 00      [17]  195         CALL    I2CRBYTE
   00BF DD 77 03      [19]  196         LD      (IX+3),A
   00C2 18 14         [12]  197         JR      ENDI2C
                            198     
   00C4                     199 SKIP:                       ; If no device present, fake an idle response
   00C4 3E 2E         [ 7]  200         LD      A,0x2e  ; '.'
   00C6 DD 77 00      [19]  201         LD      (IX),A
   00C9 18 0D         [12]  202         JR      ENDI2C
                            203 
   00CB                     204 I2CSRESP:
   00CB F5            [11]  205         PUSH    AF
   00CC CD 44 00      [17]  206         CALL    I2CSTART
   00CF 3E 10         [ 7]  207         LD      A,I2CWADR
   00D1 CD 7A 00      [17]  208         CALL    I2CWBYTE
   00D4 F1            [10]  209         POP     AF
   00D5 CD 7A 00      [17]  210         CALL    I2CWBYTE
   00D8                     211 ENDI2C:
   00D8 CD 4B 00      [17]  212         CALL    I2CSTOP
   00DB C9            [10]  213         RET
                            214 ;
                            215 
                            216 ; Main Polling loop
                            217 ; Return carry flag if we got a valid command (not idle)
   00DC                     218 POLL:
   00DC CD A0 00      [17]  219         CALL    I2CRREQ
   00DF DD 7E 00      [19]  220         LD      A,(IX)
   00E2 FE 52         [ 7]  221         CP      0x52    ; 'R' - Read memory
   00E4 28 1B         [12]  222         JR      Z,MREAD
   00E6 FE 57         [ 7]  223         CP      0x57    ; 'W' - Write memory
   00E8 28 1D         [12]  224         JR      Z,MWRITE
   00EA FE 49         [ 7]  225         CP      0x49    ; 'I' - Input from port
   00EC 28 2D         [12]  226         JR      Z,PREAD
   00EE FE 4F         [ 7]  227         CP      0x4F    ; 'O' - Output from port
   00F0 28 30         [12]  228         JR      Z,PWRITE
   00F2 FE 43         [ 7]  229         CP      0x43    ; 'C' - Call subroutine
   00F4 28 3B         [12]  230         JR      Z,REMCALL
   00F6 3F            [ 4]  231         CCF
   00F7 C9            [10]  232         RET
   00F8                     233 LOADHL:
   00F8 DD 7E 01      [19]  234         LD      A,(IX+1)
   00FB 67            [ 4]  235         LD      H,A
   00FC DD 7E 02      [19]  236         LD      A,(IX+2)
   00FF 6F            [ 4]  237         LD      L,A
   0100 C9            [10]  238         RET    
   0101                     239 MREAD:
   0101 CD 12 01      [17]  240         CALL    LOADBC
   0104 0A            [ 7]  241         LD      A,(BC)
   0105 18 25         [12]  242         JR      SRESP
   0107                     243 MWRITE:
   0107 CD 12 01      [17]  244         CALL    LOADBC
   010A DD 7E 03      [19]  245         LD      A,(IX+3)
   010D 02            [ 7]  246         LD      (BC),A
   010E 3E 57         [ 7]  247         LD      A,0x57  ;'W'
   0110 18 1A         [12]  248         JR      SRESP
   0112                     249 LOADBC:
   0112 DD 7E 01      [19]  250         LD      A,(IX+1)
   0115 47            [ 4]  251         LD      B,A
   0116 DD 7E 02      [19]  252         LD      A,(IX+2)
   0119 4F            [ 4]  253         LD      C,A
   011A C9            [10]  254         RET
   011B                     255 PREAD:
   011B CD 12 01      [17]  256         CALL    LOADBC
   011E ED 78         [12]  257         IN      A,(C)
   0120 18 0A         [12]  258         JR      SRESP
   0122                     259 PWRITE:
   0122 CD 12 01      [17]  260         CALL    LOADBC
   0125 DD 7E 03      [19]  261         LD      A,(IX+3)
   0128 ED 79         [12]  262         OUT     (C),A
   012A 3E 4F         [ 7]  263         LD      A,0x4F  ;'O'
   012C                     264 SRESP:
   012C CD CB 00      [17]  265         CALL    I2CSRESP
   012F                     266 RHERE:
   012F 37            [ 4]  267         SCF
   0130 C9            [10]  268         RET
   0131                     269 REMCALL:
   0131 21 00 00      [10]  270         LD      HL,START
   0134 E5            [11]  271         PUSH    HL
   0135 CD F8 00      [17]  272         CALL    LOADHL
   0138 E9            [ 4]  273         JP      (HL)
                            274     
   0139                     275 INIT:
   0139 31 F0 63      [10]  276         LD      SP,SSTACK   ; have to set valid SP
   013C DD 21 F0 63   [14]  277         LD      IX,CMDBUF   ; Easy to index command buffer
                            278         
                            279 ; Main routine
   0140                     280 MAIN:
   0140 CD DC 00      [17]  281         CALL    POLL
   0143 38 FB         [12]  282         JR      C,MAIN
                            283         
   0145 01 80 01      [10]  284         LD      BC,BIGDEL
   0148                     285 MLOOP:
   0148 0B            [ 6]  286         DEC     BC
   0149 79            [ 4]  287         LD      A,C
   014A B0            [ 4]  288         OR      B
   014B 20 FB         [12]  289         JR      NZ,MLOOP
   014D 18 F1         [12]  290         JR      MAIN
                            291 
                            292 
                            293     
                            294 
