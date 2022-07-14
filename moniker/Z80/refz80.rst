                              1 ;
                              2 ; Moniker - Z80 Version
                              3 ; by Frank Palazzolo
                              4 ; For ROM IO Hardware
                              5 ;
                              6 ; Note: I avoid opcode 0x32 on this platform, it will trigger
                              7 ;       the security chip on Sega Star Trek Hardware
                              8 ;
                              9         .area   CODE1   (ABS)   ; ASXXXX directive, absolute addressing
                             10 
                             11 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             12 ; You may need to adjust these variables for different targets
                             13 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             14 
                             15 ; RAM SETTINGS
                             16 
                     CFF0    17 RAMSTRT .equ    0xcff0      ; Start of RAM - need only 4 bytes here
                     CFF0    18 SSTACK  .equ    0xcff0      ; Start of stack
                             19 
                             20 ; ROM SETTINGS - usually the first 2K of memory for z80
                             21 
                     0000    22 SCHIP   .equ    0x0000          ;start of chip memory mapping
                             23 
                     0400    24 IOREG   .equ	SCHIP+0x0400    ;reserved region for IO
                             25 
                             26 ; TIMER SETTING
                     0180    27 BIGDEL  .equ    0x0180      ;delay factor
                             28 
                     0011    29 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    30 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                             31 
                             32 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             33 ; RAM Variables	
                             34 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             35 
                     CFF0    36 CMDBUF  .equ    RAMSTRT         ; Need only 4 bytes of ram for command buffer
                             37                                 ; (We will save 12 more just in case)
                             38 
   0000                      39         .org    SCHIP
                             40     
   0000 F3            [ 4]   41 START:  DI                  ; Disable interrupts - we don't handle them
   0001 C3 29 01      [10]   42         JP      INIT        ; go to initialization code
                             43     
                             44 ; Set the SCL pin high
                             45 ; D is the global coin counter buffer
                             46 ; Destroys A
   0004                      47 SETSCL:
   0004 7A            [ 4]   48         LD      A,D
   0005 F6 01         [ 7]   49         OR      0x01
   0007 57            [ 4]   50         LD      D,A
   0008 E5            [11]   51         PUSH    HL
   0009 26 04         [ 7]   52         LD      H,#>IOREG
   000B 6F            [ 4]   53         LD      L,A
   000C 7E            [ 7]   54         LD      A,(HL)
   000D E1            [10]   55         POP     HL
   000E CD 42 00      [17]   56         CALL    I2CDELAY
   0011 C9            [10]   57         RET
                             58     
                             59 ; Set the SCL pin low
                             60 ; D is the global coin counter buffer
                             61 ; Destroys A
   0012                      62 CLRSCL:
   0012 7A            [ 4]   63         LD      A,D
   0013 E6 FE         [ 7]   64         AND     0xFE
   0015 57            [ 4]   65         LD      D,A
   0016 E5            [11]   66         PUSH    HL
   0017 26 04         [ 7]   67         LD      H,#>IOREG
   0019 6F            [ 4]   68         LD      L,A
   001A 7E            [ 7]   69         LD      A,(HL)
   001B E1            [10]   70         POP     HL
   001C C9            [10]   71         RET
                             72 
                             73 ; Set the DOUT pin low
                             74 ; D is the global coin counter buffer
                             75 ; Destroys A 
   001D                      76 SETSDA:
   001D 7A            [ 4]   77         LD      A,D
   001E E6 FD         [ 7]   78         AND     0xFD
   0020 57            [ 4]   79         LD      D,A
   0021 E5            [11]   80         PUSH    HL
   0022 26 04         [ 7]   81         LD      H,#>IOREG
   0024 6F            [ 4]   82         LD      L,A
   0025 7E            [ 7]   83         LD      A,(HL)
   0026 E1            [10]   84         POP     HL
   0027 CD 42 00      [17]   85         CALL    I2CDELAY
   002A C9            [10]   86         RET
                             87 
                             88 ; Set the DOUT pin high
                             89 ; D is the global coin counter buffer
                             90 ; Destroys A  
   002B                      91 CLRSDA:
   002B 7A            [ 4]   92         LD      A,D
   002C F6 02         [ 7]   93         OR      0x02
   002E 57            [ 4]   94         LD      D,A
   002F E5            [11]   95         PUSH    HL
   0030 26 04         [ 7]   96         LD      H,#>IOREG
   0032 6F            [ 4]   97         LD      L,A
   0033 7E            [ 7]   98         LD      A,(HL)
   0034 E1            [10]   99         POP     HL
   0035 CD 42 00      [17]  100         CALL    I2CDELAY
   0038 C9            [10]  101         RET
                            102 
                            103 ; Read the DIN pin 
                            104 ; returns bit in carry flag    
   0039                     105 READSDA:
   0039 E5            [11]  106         PUSH    HL
   003A 26 04         [ 7]  107         LD      H,#>IOREG
   003C 6F            [ 4]  108         LD      L,A
   003D 7E            [ 7]  109         LD      A,(HL)
   003E E1            [10]  110         POP     HL
   003F CB 3F         [ 8]  111         SRL     A           ;carry flag
   0041 C9            [10]  112         RET
                            113     
                            114 ; Delay for half a bit time
   0042                     115 I2CDELAY:
   0042 C9            [10]  116         RET     ; This is plenty
                            117 
                            118 ; I2C Start Condition
                            119 ; Uses HL
                            120 ; Destroys A
   0043                     121 I2CSTART:
   0043 CD 2B 00      [17]  122         CALL    CLRSDA      
   0046 CD 12 00      [17]  123         CALL    CLRSCL
   0049 C9            [10]  124         RET
                            125 
                            126 ; I2C Stop Condition
                            127 ; Uses HL
                            128 ; Destroys A
   004A                     129 I2CSTOP:
   004A CD 2B 00      [17]  130         CALL    CLRSDA
   004D CD 04 00      [17]  131         CALL    SETSCL
   0050 CD 1D 00      [17]  132         CALL    SETSDA
   0053 C9            [10]  133         RET
                            134 
                            135 ; I2C Read Bit routine
                            136 ; Returns bit in carry blag
                            137 ; Destroys A
   0054                     138 I2CRBIT:
   0054 CD 1D 00      [17]  139         CALL    SETSDA
   0057 CD 04 00      [17]  140         CALL    SETSCL
   005A CD 39 00      [17]  141         CALL    READSDA
   005D F5            [11]  142         PUSH    AF          ; save carry flag
   005E CD 12 00      [17]  143         CALL    CLRSCL
   0061 F1            [10]  144         POP     AF          ; rv in carry flag
   0062 C9            [10]  145         RET
                            146 
                            147 ; I2C Write Bit routine
                            148 ; Takes carry flag
                            149 ; Destroys A
   0063                     150 I2CWBIT:
   0063 30 05         [12]  151         JR      NC,DOCLR
   0065 CD 1D 00      [17]  152         CALL    SETSDA
   0068 18 03         [12]  153         JR      AHEAD
   006A                     154 DOCLR:
   006A CD 2B 00      [17]  155         CALL    CLRSDA
   006D                     156 AHEAD:
   006D CD 04 00      [17]  157         CALL    SETSCL
   0070 CD 12 00      [17]  158         CALL    CLRSCL
   0073 C9            [10]  159         RET
                            160         
                            161         ; Make sure this code ends before address 0x66 !
                            162         
   0066                     163         .org    0x0066
                            164 
   0066 ED 45         [14]  165 NMI:    RETN
                            166 
                            167 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            168 ; This function is called once, and should be used do any game-specific
                            169 ; initialization that is required
                            170 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            171 
   0068                     172 ONCE:   
                            173 ;       YOUR CODE CAN GO HERE
   0068 C9            [10]  174         RET
                            175 
   0069                     176 EVERY:  
                            177 ;       YOUR CODE CAN GO HERE
   0069 C9            [10]  178         RET
                            179 
                            180 ; I2C Write Byte routine
                            181 ; Takes A
                            182 ; Destroys B
                            183 ; Returns carry bit
   006A                     184 I2CWBYTE:
   006A 06 08         [ 7]  185         LD      B,8
   006C                     186 ILOOP:
   006C C5            [11]  187         PUSH    BC          ; save B
   006D CB 07         [ 8]  188         RLC     A    
   006F F5            [11]  189         PUSH    AF          ; save A
   0070 CD 63 00      [17]  190         CALL    I2CWBIT
   0073 F1            [10]  191         POP     AF
   0074 C1            [10]  192         POP     BC
   0075 10 F5         [13]  193         DJNZ    ILOOP
   0077 CD 54 00      [17]  194         CALL    I2CRBIT
   007A C9            [10]  195         RET
                            196 
                            197 ; I2C Read Byte routine
                            198 ; Destroys BC
                            199 ; Returns A
   007B                     200 I2CRBYTE:
   007B 06 08         [ 7]  201         LD      B,8
   007D 0E 00         [ 7]  202         LD      C,0
   007F                     203 LOOP3:
   007F C5            [11]  204         PUSH    BC
   0080 CD 54 00      [17]  205         CALL    I2CRBIT     ; get bit in carry flag
   0083 C1            [10]  206         POP     BC
   0084 CB 11         [ 8]  207         RL      C           ; rotate carry into bit0 of C register
   0086 10 F7         [13]  208         DJNZ    LOOP3
   0088 AF            [ 4]  209         XOR     A           ; clear carry flag              
   0089 C5            [11]  210         PUSH    BC
   008A CD 63 00      [17]  211         CALL    I2CWBIT
   008D C1            [10]  212         POP     BC
   008E 79            [ 4]  213         LD      A,C
   008F C9            [10]  214         RET
                            215 ;
                            216 
                            217 ; Read 4-byte I2C Command from device into CMDBUF
                            218 ; Uses HL
                            219 ; Destroys A,BC,HL
   0090                     220 I2CRREQ:
   0090 CD 43 00      [17]  221         CALL    I2CSTART
   0093 3E 11         [ 7]  222         LD      A,I2CRADR
   0095 CD 6A 00      [17]  223         CALL    I2CWBYTE
   0098 38 1A         [12]  224         JR      C,SKIP
   009A CD 7B 00      [17]  225         CALL    I2CRBYTE
   009D DD 77 00      [19]  226         LD      (IX),A
   00A0 CD 7B 00      [17]  227         CALL    I2CRBYTE
   00A3 DD 77 01      [19]  228         LD      (IX+1),A  
   00A6 CD 7B 00      [17]  229         CALL    I2CRBYTE
   00A9 DD 77 02      [19]  230         LD      (IX+2),A
   00AC CD 7B 00      [17]  231         CALL    I2CRBYTE
   00AF DD 77 03      [19]  232         LD      (IX+3),A
   00B2 18 14         [12]  233         JR      ENDI2C
                            234     
   00B4                     235 SKIP:                       ; If no device present, fake an idle response
   00B4 3E 2E         [ 7]  236         LD      A,0x2e  ; '.'
   00B6 DD 77 00      [19]  237         LD      (IX),A
   00B9 18 0D         [12]  238         JR      ENDI2C
                            239 
   00BB                     240 I2CSRESP:
   00BB F5            [11]  241         PUSH    AF
   00BC CD 43 00      [17]  242         CALL    I2CSTART
   00BF 3E 10         [ 7]  243         LD      A,I2CWADR
   00C1 CD 6A 00      [17]  244         CALL    I2CWBYTE
   00C4 F1            [10]  245         POP     AF
   00C5 CD 6A 00      [17]  246         CALL    I2CWBYTE
   00C8                     247 ENDI2C:
   00C8 CD 4A 00      [17]  248         CALL    I2CSTOP
   00CB C9            [10]  249         RET
                            250 ;
                            251 
                            252 ; Main Polling loop
                            253 ; Return carry flag if we got a valid command (not idle)
   00CC                     254 POLL:
   00CC CD 90 00      [17]  255         CALL    I2CRREQ
   00CF DD 7E 00      [19]  256         LD      A,(IX)
   00D2 FE 52         [ 7]  257         CP      0x52    ; 'R' - Read memory
   00D4 28 1B         [12]  258         JR      Z,MREAD
   00D6 FE 57         [ 7]  259         CP      0x57    ; 'W' - Write memory
   00D8 28 1D         [12]  260         JR      Z,MWRITE
   00DA FE 49         [ 7]  261         CP      0x49    ; 'I' - Input from port
   00DC 28 2D         [12]  262         JR      Z,PREAD
   00DE FE 4F         [ 7]  263         CP      0x4F    ; 'O' - Output from port
   00E0 28 30         [12]  264         JR      Z,PWRITE
   00E2 FE 43         [ 7]  265         CP      0x43    ; 'C' - Call subroutine
   00E4 28 3B         [12]  266         JR      Z,REMCALL
   00E6 3F            [ 4]  267         CCF
   00E7 C9            [10]  268         RET
   00E8                     269 LOADHL:
   00E8 DD 7E 01      [19]  270         LD      A,(IX+1)
   00EB 67            [ 4]  271         LD      H,A
   00EC DD 7E 02      [19]  272         LD      A,(IX+2)
   00EF 6F            [ 4]  273         LD      L,A
   00F0 C9            [10]  274         RET    
   00F1                     275 MREAD:
   00F1 CD 02 01      [17]  276         CALL    LOADBC
   00F4 0A            [ 7]  277         LD      A,(BC)
   00F5 18 25         [12]  278         JR      SRESP
   00F7                     279 MWRITE:
   00F7 CD 02 01      [17]  280         CALL    LOADBC
   00FA DD 7E 03      [19]  281         LD      A,(IX+3)
   00FD 02            [ 7]  282         LD      (BC),A
   00FE 3E 57         [ 7]  283         LD      A,0x57  ;'W'
   0100 18 1A         [12]  284         JR      SRESP
   0102                     285 LOADBC:
   0102 DD 7E 01      [19]  286         LD      A,(IX+1)
   0105 47            [ 4]  287         LD      B,A
   0106 DD 7E 02      [19]  288         LD      A,(IX+2)
   0109 4F            [ 4]  289         LD      C,A
   010A C9            [10]  290         RET
   010B                     291 PREAD:
   010B CD 02 01      [17]  292         CALL    LOADBC
   010E ED 78         [12]  293         IN      A,(C)
   0110 18 0A         [12]  294         JR      SRESP
   0112                     295 PWRITE:
   0112 CD 02 01      [17]  296         CALL    LOADBC
   0115 DD 7E 03      [19]  297         LD      A,(IX+3)
   0118 ED 79         [12]  298         OUT     (C),A
   011A 3E 4F         [ 7]  299         LD      A,0x4F  ;'O'
   011C                     300 SRESP:
   011C CD BB 00      [17]  301         CALL    I2CSRESP
   011F                     302 RHERE:
   011F 37            [ 4]  303         SCF
   0120 C9            [10]  304         RET
   0121                     305 REMCALL:
   0121 21 00 00      [10]  306         LD      HL,START
   0124 E5            [11]  307         PUSH    HL
   0125 CD E8 00      [17]  308         CALL    LOADHL
   0128 E9            [ 4]  309         JP      (HL)
                            310     
   0129                     311 INIT:
   0129 31 F0 CF      [10]  312         LD      SP,SSTACK   ; have to set valid SP
   012C DD 21 F0 CF   [14]  313         LD      IX,CMDBUF   ; Easy to index command buffer
                            314         
   0130 CD 68 00      [17]  315         CALL    ONCE
                            316 
                            317 ; Main routine
   0133                     318 MAIN:
   0133 CD 69 00      [17]  319         CALL    EVERY
   0136 CD CC 00      [17]  320         CALL    POLL
   0139 38 F8         [12]  321         JR      C,MAIN
                            322         
   013B 01 80 01      [10]  323         LD      BC,BIGDEL
   013E                     324 MLOOP:
   013E 0B            [ 6]  325         DEC     BC
   013F 79            [ 4]  326         LD      A,C
   0140 B0            [ 4]  327         OR      B
   0141 20 FB         [12]  328         JR      NZ,MLOOP
   0143 18 EE         [12]  329         JR      MAIN
                            330 
                            331 
                            332     
                            333 
