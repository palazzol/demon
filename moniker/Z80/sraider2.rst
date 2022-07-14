                              1 ;
                              2 ; Moniker - Z80 Version
                              3 ; by Frank Palazzolo
                              4 ; For ROM IO Hardware
                              5 ;
                              6 ; Note: I avoid opcode 0x32 on this platform, it will trigger
                              7 ;       the security chip on Sega Star Trek Hardware
                              8 ;
                              9 
                             10         
                             11 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             12 ; You may need to adjust these variables for different targets
                             13 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             14 
                             15 ; RAM SETTINGS
                             16 
                     63F0    17 RAMSTRT .equ    0x63f0      ; Start of RAM - need only 4 bytes here
                     63F0    18 SSTACK  .equ    0x63f0      ; Start of stack
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
                     63F0    36 CMDBUF  .equ    RAMSTRT         ; Need only 4 bytes of ram for command buffer
                             37                                 ; (We will save 12 more just in case)
                             38 
                             39         .bank   first   (base=SCHIP, size=0x0066)
                             40         .bank   second  (base=SCHIP+0x0066, size=0x0400-0x66)
                             41 
                             42         .area   first   (ABS, BANK=first)   ; ASXXXX directive, relative addressing
                             43     
   0000 F3            [ 4]   44 START:  DI                  ; Disable interrupts - we don't handle them
   0001 C3 3A 01      [10]   45         JP      INIT        ; go to initialization code
                             46     
                             47 ; Set the SCL pin high
                             48 ; D is the global coin counter buffer
                             49 ; Destroys A
   0004                      50 SETSCL:
   0004 7A            [ 4]   51         LD      A,D
   0005 F6 01         [ 7]   52         OR      0x01
   0007 57            [ 4]   53         LD      D,A
   0008 E5            [11]   54         PUSH    HL
   0009 26 04         [ 7]   55         LD      H,#>IOREG
   000B 6F            [ 4]   56         LD      L,A
   000C 7E            [ 7]   57         LD      A,(HL)
   000D E1            [10]   58         POP     HL
   000E CD 43 00      [17]   59         CALL    I2CDELAY
   0011 C9            [10]   60         RET
                             61     
                             62 ; Set the SCL pin low
                             63 ; D is the global coin counter buffer
                             64 ; Destroys A
   0012                      65 CLRSCL:
   0012 7A            [ 4]   66         LD      A,D
   0013 E6 FE         [ 7]   67         AND     0xFE
   0015 57            [ 4]   68         LD      D,A
   0016 E5            [11]   69         PUSH    HL
   0017 26 04         [ 7]   70         LD      H,#>IOREG
   0019 6F            [ 4]   71         LD      L,A
   001A 7E            [ 7]   72         LD      A,(HL)
   001B E1            [10]   73         POP     HL
   001C C9            [10]   74         RET
                             75 
                             76 ; Set the DOUT pin low
                             77 ; D is the global coin counter buffer
                             78 ; Destroys A 
   001D                      79 SETSDA:
   001D 7A            [ 4]   80         LD      A,D
   001E E6 FD         [ 7]   81         AND     0xFD
   0020 57            [ 4]   82         LD      D,A
   0021 E5            [11]   83         PUSH    HL
   0022 26 04         [ 7]   84         LD      H,#>IOREG
   0024 6F            [ 4]   85         LD      L,A
   0025 7E            [ 7]   86         LD      A,(HL)
   0026 E1            [10]   87         POP     HL
   0027 CD 43 00      [17]   88         CALL    I2CDELAY
   002A C9            [10]   89         RET
                             90 
                             91 ; Set the DOUT pin high
                             92 ; D is the global coin counter buffer
                             93 ; Destroys A  
   002B                      94 CLRSDA:
   002B 7A            [ 4]   95         LD      A,D
   002C F6 02         [ 7]   96         OR      0x02
   002E 57            [ 4]   97         LD      D,A
   002F E5            [11]   98         PUSH    HL
   0030 26 04         [ 7]   99         LD      H,#>IOREG
   0032 6F            [ 4]  100         LD      L,A
   0033 7E            [ 7]  101         LD      A,(HL)
   0034 E1            [10]  102         POP     HL
   0035 CD 43 00      [17]  103         CALL    I2CDELAY
   0038 C9            [10]  104         RET
                            105 
                            106 ; Read the DIN pin 
                            107 ; returns bit in carry flag    
   0039                     108 READSDA:
   0039 7A            [ 4]  109         LD      A,D
   003A E5            [11]  110         PUSH    HL
   003B 26 04         [ 7]  111         LD      H,#>IOREG
   003D 6F            [ 4]  112         LD      L,A
   003E 7E            [ 7]  113         LD      A,(HL)
   003F E1            [10]  114         POP     HL
   0040 CB 3F         [ 8]  115         SRL     A           ;carry flag
   0042 C9            [10]  116         RET
                            117     
                            118 ; Delay for half a bit time
   0043                     119 I2CDELAY:
   0043 C9            [10]  120         RET     ; This is plenty
                            121 
                            122 ; I2C Start Condition
                            123 ; Uses HL
                            124 ; Destroys A
   0044                     125 I2CSTART:
   0044 CD 2B 00      [17]  126         CALL    CLRSDA      
   0047 CD 12 00      [17]  127         CALL    CLRSCL
   004A C9            [10]  128         RET
                            129 
                            130 ; I2C Stop Condition
                            131 ; Uses HL
                            132 ; Destroys A
   004B                     133 I2CSTOP:
   004B CD 2B 00      [17]  134         CALL    CLRSDA
   004E CD 04 00      [17]  135         CALL    SETSCL
   0051 CD 1D 00      [17]  136         CALL    SETSDA
   0054 C9            [10]  137         RET
                            138 
                            139 ; I2C Read Bit routine
                            140 ; Returns bit in carry blag
                            141 ; Destroys A
   0055                     142 I2CRBIT:
   0055 CD 1D 00      [17]  143         CALL    SETSDA
   0058 CD 04 00      [17]  144         CALL    SETSCL
   005B CD 39 00      [17]  145         CALL    READSDA
   005E F5            [11]  146         PUSH    AF          ; save carry flag
   005F CD 12 00      [17]  147         CALL    CLRSCL
   0062 F1            [10]  148         POP     AF          ; rv in carry flag
   0063 C9            [10]  149         RET
                            150 
                            151          .area   second   (ABS, BANK=second)   ; ASXXXX directive, relative addressing
                            152 ; NMI Handler must be first thing in this bank
   0066 ED 45         [14]  153 NMI:    RETN
                            154 
                            155 ; I2C Write Bit routine
                            156 ; Takes carry flag
                            157 ; Destroys A
   0068                     158 I2CWBIT:
   0068 30 05         [12]  159         JR      NC,DOCLR
   006A CD 1D 00      [17]  160         CALL    SETSDA
   006D 18 03         [12]  161         JR      AHEAD
   006F                     162 DOCLR:
   006F CD 2B 00      [17]  163         CALL    CLRSDA
   0072                     164 AHEAD:
   0072 CD 04 00      [17]  165         CALL    SETSCL
   0075 CD 12 00      [17]  166         CALL    CLRSCL
   0078 C9            [10]  167         RET
                            168 
                            169 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            170 ; This function is called once, and should be used do any game-specific
                            171 ; initialization that is required
                            172 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            173 
   0079                     174 ONCE:   
                            175 ;       YOUR CODE CAN GO HERE
   0079 C9            [10]  176         RET
                            177 
   007A                     178 EVERY:  
                            179 ;       YOUR CODE CAN GO HERE
   007A C9            [10]  180         RET
                            181 
                            182 ; I2C Write Byte routine
                            183 ; Takes A
                            184 ; Destroys B
                            185 ; Returns carry bit
   007B                     186 I2CWBYTE:
   007B 06 08         [ 7]  187         LD      B,8
   007D                     188 ILOOP:
   007D C5            [11]  189         PUSH    BC          ; save B
   007E CB 07         [ 8]  190         RLC     A    
   0080 F5            [11]  191         PUSH    AF          ; save A
   0081 CD 68 00      [17]  192         CALL    I2CWBIT
   0084 F1            [10]  193         POP     AF
   0085 C1            [10]  194         POP     BC
   0086 10 F5         [13]  195         DJNZ    ILOOP
   0088 CD 55 00      [17]  196         CALL    I2CRBIT
   008B C9            [10]  197         RET
                            198 
                            199 ; I2C Read Byte routine
                            200 ; Destroys BC
                            201 ; Returns A
   008C                     202 I2CRBYTE:
   008C 06 08         [ 7]  203         LD      B,8
   008E 0E 00         [ 7]  204         LD      C,0
   0090                     205 LOOP3:
   0090 C5            [11]  206         PUSH    BC
   0091 CD 55 00      [17]  207         CALL    I2CRBIT     ; get bit in carry flag
   0094 C1            [10]  208         POP     BC
   0095 CB 11         [ 8]  209         RL      C           ; rotate carry into bit0 of C register
   0097 10 F7         [13]  210         DJNZ    LOOP3
   0099 AF            [ 4]  211         XOR     A           ; clear carry flag              
   009A C5            [11]  212         PUSH    BC
   009B CD 68 00      [17]  213         CALL    I2CWBIT
   009E C1            [10]  214         POP     BC
   009F 79            [ 4]  215         LD      A,C
   00A0 C9            [10]  216         RET
                            217 ;
                            218 
                            219 ; Read 4-byte I2C Command from device into CMDBUF
                            220 ; Uses HL
                            221 ; Destroys A,BC,HL
   00A1                     222 I2CRREQ:
   00A1 CD 44 00      [17]  223         CALL    I2CSTART
   00A4 3E 11         [ 7]  224         LD      A,I2CRADR
   00A6 CD 7B 00      [17]  225         CALL    I2CWBYTE
   00A9 38 1A         [12]  226         JR      C,SKIP
   00AB CD 8C 00      [17]  227         CALL    I2CRBYTE
   00AE DD 77 00      [19]  228         LD      (IX),A
   00B1 CD 8C 00      [17]  229         CALL    I2CRBYTE
   00B4 DD 77 01      [19]  230         LD      (IX+1),A  
   00B7 CD 8C 00      [17]  231         CALL    I2CRBYTE
   00BA DD 77 02      [19]  232         LD      (IX+2),A
   00BD CD 8C 00      [17]  233         CALL    I2CRBYTE
   00C0 DD 77 03      [19]  234         LD      (IX+3),A
   00C3 18 14         [12]  235         JR      ENDI2C
                            236     
   00C5                     237 SKIP:                       ; If no device present, fake an idle response
   00C5 3E 2E         [ 7]  238         LD      A,0x2e  ; '.'
   00C7 DD 77 00      [19]  239         LD      (IX),A
   00CA 18 0D         [12]  240         JR      ENDI2C
                            241 
   00CC                     242 I2CSRESP:
   00CC F5            [11]  243         PUSH    AF
   00CD CD 44 00      [17]  244         CALL    I2CSTART
   00D0 3E 10         [ 7]  245         LD      A,I2CWADR
   00D2 CD 7B 00      [17]  246         CALL    I2CWBYTE
   00D5 F1            [10]  247         POP     AF
   00D6 CD 7B 00      [17]  248         CALL    I2CWBYTE
   00D9                     249 ENDI2C:
   00D9 CD 4B 00      [17]  250         CALL    I2CSTOP
   00DC C9            [10]  251         RET
                            252 ;
                            253 
                            254 ; Main Polling loop
                            255 ; Return carry flag if we got a valid command (not idle)
   00DD                     256 POLL:
   00DD CD A1 00      [17]  257         CALL    I2CRREQ
   00E0 DD 7E 00      [19]  258         LD      A,(IX)
   00E3 FE 52         [ 7]  259         CP      0x52    ; 'R' - Read memory
   00E5 28 1B         [12]  260         JR      Z,MREAD
   00E7 FE 57         [ 7]  261         CP      0x57    ; 'W' - Write memory
   00E9 28 1D         [12]  262         JR      Z,MWRITE
   00EB FE 49         [ 7]  263         CP      0x49    ; 'I' - Input from port
   00ED 28 2D         [12]  264         JR      Z,PREAD
   00EF FE 4F         [ 7]  265         CP      0x4F    ; 'O' - Output from port
   00F1 28 30         [12]  266         JR      Z,PWRITE
   00F3 FE 43         [ 7]  267         CP      0x43    ; 'C' - Call subroutine
   00F5 28 3B         [12]  268         JR      Z,REMCALL
   00F7 3F            [ 4]  269         CCF
   00F8 C9            [10]  270         RET
   00F9                     271 LOADHL:
   00F9 DD 7E 01      [19]  272         LD      A,(IX+1)
   00FC 67            [ 4]  273         LD      H,A
   00FD DD 7E 02      [19]  274         LD      A,(IX+2)
   0100 6F            [ 4]  275         LD      L,A
   0101 C9            [10]  276         RET    
   0102                     277 MREAD:
   0102 CD 13 01      [17]  278         CALL    LOADBC
   0105 0A            [ 7]  279         LD      A,(BC)
   0106 18 25         [12]  280         JR      SRESP
   0108                     281 MWRITE:
   0108 CD 13 01      [17]  282         CALL    LOADBC
   010B DD 7E 03      [19]  283         LD      A,(IX+3)
   010E 02            [ 7]  284         LD      (BC),A
   010F 3E 57         [ 7]  285         LD      A,0x57  ;'W'
   0111 18 1A         [12]  286         JR      SRESP
   0113                     287 LOADBC:
   0113 DD 7E 01      [19]  288         LD      A,(IX+1)
   0116 47            [ 4]  289         LD      B,A
   0117 DD 7E 02      [19]  290         LD      A,(IX+2)
   011A 4F            [ 4]  291         LD      C,A
   011B C9            [10]  292         RET
   011C                     293 PREAD:
   011C CD 13 01      [17]  294         CALL    LOADBC
   011F ED 78         [12]  295         IN      A,(C)
   0121 18 0A         [12]  296         JR      SRESP
   0123                     297 PWRITE:
   0123 CD 13 01      [17]  298         CALL    LOADBC
   0126 DD 7E 03      [19]  299         LD      A,(IX+3)
   0129 ED 79         [12]  300         OUT     (C),A
   012B 3E 4F         [ 7]  301         LD      A,0x4F  ;'O'
   012D                     302 SRESP:
   012D CD CC 00      [17]  303         CALL    I2CSRESP
   0130                     304 RHERE:
   0130 37            [ 4]  305         SCF
   0131 C9            [10]  306         RET
   0132                     307 REMCALL:
   0132 21 00 00      [10]  308         LD      HL,START
   0135 E5            [11]  309         PUSH    HL
   0136 CD F9 00      [17]  310         CALL    LOADHL
   0139 E9            [ 4]  311         JP      (HL)
                            312     
   013A                     313 INIT:
   013A 31 F0 63      [10]  314         LD      SP,SSTACK   ; have to set valid SP
   013D DD 21 F0 63   [14]  315         LD      IX,CMDBUF   ; Easy to index command buffer
                            316         
   0141 CD 79 00      [17]  317         CALL    ONCE
                            318 
                            319 ; Main routine
   0144                     320 MAIN:
   0144 CD 7A 00      [17]  321         CALL    EVERY
   0147 CD DD 00      [17]  322         CALL    POLL
   014A 38 F8         [12]  323         JR      C,MAIN
                            324         
   014C 01 80 01      [10]  325         LD      BC,BIGDEL
   014F                     326 MLOOP:
   014F 0B            [ 6]  327         DEC     BC
   0150 79            [ 4]  328         LD      A,C
   0151 B0            [ 4]  329         OR      B
   0152 20 FB         [12]  330         JR      NZ,MLOOP
   0154 18 EE         [12]  331         JR      MAIN
                            332 
                            333 
                            334     
                            335 
