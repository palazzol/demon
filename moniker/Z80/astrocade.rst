                              1 ;
                              2 ; Moniker - Z80 Version, 2716 version in Bally Astrocade cartridge
                              3 ; by Frank Palazzolo
                              4 ;
                              5 ; "2716" Memory Map
                              6 ; X000-X3FF - ROM
                              7 ; X400-X5FF - I/O (Special region)
                              8 ; X600-X7FF - ROM
                              9 
                             10 ; SCL connected to A0
                             11 ; DOUT connected to A1
                             12 ; DIN connected to D0
                             13 
                             14 ; "Special Region"
                             15 ; Read from X4X0 - clear SCL, clear DOUT
                             16 ; Read from X4X1 -   set SCL, clear DOUT
                             17 ; Read from X4X2 - clear SCL,   set DOUT
                             18 ; Read from X4X3 -   set SCL,   set DOUT
                             19 ; All reads return DIN as bit 0
                             20 
                             21         .area   CODE1   (ABS)   ; ASXXXX directive, absolute addressing
                             22 
                             23 ;DSPORT  .equ    0x13        ; dip switch 1 port
                             24 ;CCPORT  .equ    0x16        ; port for lamps
                             25 
                     4FCE    26 CMDBUF  .equ    0x4fce      ; Need only 4 bytes of ram for command buffer
                             27                             ; (We will save 12 more just in case)
                             28 ;SSTACK  .equ    0xdff0      ; Start of stack
                             29 
                     0011    30 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    31 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                             32 
                     0180    33 BIGDEL  .equ    0x0180      ; bigger delay, for now still fairly small
                             34 
   2000                      35         .org    0x2000	    ; cartridge start
                             36         
   2000 55                   37         .byte   0x55	    ; cartridge header
   2001 18 02                38         .word   0x0218	    ; next menu item (first one)
   2003 19 20                39         .word   TITLE	    ; title pointer
   2005 5B 21                40         .word   START	    ; start pointer
                             41         
   2007 C9            [10]   42         ret		    ; rst8
   2008 00            [ 4]   43         nop
   2009 00            [ 4]   44         nop
                             45 
   200A C9            [10]   46         ret		    ; rst16
   200B 00            [ 4]   47         nop
   200C 00            [ 4]   48         nop
                             49         
   200D C9            [10]   50 	ret		    ; rst24
   200E 00            [ 4]   51 	nop
   200F 00            [ 4]   52         nop
                             53         
   2010 C9            [10]   54 	ret		    ; rst32
   2011 00            [ 4]   55 	nop
   2012 00            [ 4]   56         nop
                             57         
   2013 C9            [10]   58 	ret		    ; rst40
   2014 00            [ 4]   59 	nop
   2015 00            [ 4]   60         nop
                             61         
   2016 C9            [10]   62 	ret		    ; rst48
   2017 00            [ 4]   63 	nop
   2018 00            [ 4]   64         nop
                             65         
   2019 44 45 4D 4F 4E 20    66 TITLE:	.ascii	"DEMON DEBUGGER"
        44 45 42 55 47 47
        45 52
   2027 00                   67 	.byte	0x00
                             68 
                             69 ; Set the SCL pin high
                             70 ; D is the global buffer
                             71 ; Destroys A
   2028                      72 SETSCL:
   2028 7A            [ 4]   73         LD      A,D
   2029 F6 01         [ 7]   74         OR      0x01
   202B 57            [ 4]   75         LD      D,A
   202C E5            [11]   76         PUSH    HL
   202D 26 24         [ 7]   77         LD      H,0x24
   202F 6F            [ 4]   78         LD      L,A
   2030 7E            [ 7]   79         LD      A,(HL)
   2031 E1            [10]   80         POP     HL
   2032 CD 6A 20      [17]   81         CALL    I2CDELAY
   2035 C9            [10]   82         RET
                             83     
                             84 ; Set the SCL pin low
                             85 ; D is the global buffer
                             86 ; Destroys A
   2036                      87 CLRSCL:
   2036 7A            [ 4]   88         LD      A,D
   2037 E6 FE         [ 7]   89         AND     0xfe
   2039 57            [ 4]   90         LD      D,A
   203A E5            [11]   91         PUSH    HL
   203B 26 24         [ 7]   92         LD      H,0x24
   203D 6F            [ 4]   93         LD      L,A
   203E 7E            [ 7]   94         LD      A,(HL)
   203F E1            [10]   95         POP     HL
   2040 CD 6A 20      [17]   96         CALL    I2CDELAY
   2043 C9            [10]   97         RET
                             98 
                             99 ; Set the DOUT pin low
                            100 ; D is the global buffer
                            101 ; Destroys A 
   2044                     102 SETSDA:
   2044 7A            [ 4]  103         LD      A,D
   2045 E6 FD         [ 7]  104         AND     0xfd
   2047 57            [ 4]  105         LD      D,A
   2048 E5            [11]  106         PUSH    HL
   2049 26 24         [ 7]  107         LD      H,0x24
   204B 6F            [ 4]  108         LD      L,A
   204C 7E            [ 7]  109         LD      A,(HL)
   204D E1            [10]  110         POP     HL
   204E CD 6A 20      [17]  111         CALL    I2CDELAY
   2051 C9            [10]  112         RET
                            113 
                            114 ; Set the DOUT pin high
                            115 ; D is the global buffer
                            116 ; Destroys A  
   2052                     117 CLRSDA:
   2052 7A            [ 4]  118         LD      A,D
   2053 F6 02         [ 7]  119         OR      0x02
   2055 57            [ 4]  120         LD      D,A
   2056 E5            [11]  121         PUSH    HL
   2057 26 24         [ 7]  122         LD      H,0x24
   2059 6F            [ 4]  123         LD      L,A
   205A 7E            [ 7]  124         LD      A,(HL)
   205B E1            [10]  125         POP     HL
   205C CD 6A 20      [17]  126         CALL    I2CDELAY
   205F C9            [10]  127         RET
                            128 
                            129 ; Read the DIN pin 
                            130 ; returns bit in carry flag    
   2060                     131 READSDA:
   2060 7A            [ 4]  132         LD      A,D
   2061 E5            [11]  133         PUSH    HL
   2062 26 24         [ 7]  134         LD      H,0x24
   2064 6F            [ 4]  135         LD      L,A
   2065 7E            [ 7]  136         LD      A,(HL)
   2066 E1            [10]  137         POP     HL
   2067 CB 3F         [ 8]  138         SRL     A           ;carry flag
   2069 C9            [10]  139         RET
                            140     
                            141 ; Delay for half a bit time
   206A                     142 I2CDELAY:
   206A C9            [10]  143         RET     ; This is plenty
                            144 
                            145 ; I2C Start Condition
                            146 ; Uses HL
                            147 ; Destroys A
   206B                     148 I2CSTART:
   206B CD 52 20      [17]  149         CALL    CLRSDA      
   206E CD 36 20      [17]  150         CALL    CLRSCL
   2071 C9            [10]  151         RET
                            152 
                            153 ; I2C Stop Condition
                            154 ; Uses HL
                            155 ; Destroys A
   2072                     156 I2CSTOP:
   2072 CD 52 20      [17]  157         CALL    CLRSDA
   2075 CD 28 20      [17]  158         CALL    SETSCL
   2078 CD 44 20      [17]  159         CALL    SETSDA
   207B C9            [10]  160         RET
                            161 
                            162 ; I2C Read Bit routine
                            163 ; Returns bit in carry blag
                            164 ; Destroys A
   207C                     165 I2CRBIT:
   207C CD 44 20      [17]  166         CALL    SETSDA
   207F CD 28 20      [17]  167         CALL    SETSCL
   2082 CD 60 20      [17]  168         CALL    READSDA
   2085 F5            [11]  169         PUSH    AF          ; save carry flag
   2086 CD 36 20      [17]  170         CALL    CLRSCL
   2089 F1            [10]  171         POP     AF          ; rv in carry flag
   208A C9            [10]  172         RET
                            173 
                            174 ; I2C Write Bit routine
                            175 ; Takes carry flag
                            176 ; Destroys A
   208B                     177 I2CWBIT:
   208B 30 05         [12]  178         JR      NC,DOCLR
   208D CD 44 20      [17]  179         CALL    SETSDA
   2090 18 03         [12]  180         JR      AHEAD
   2092                     181 DOCLR:
   2092 CD 52 20      [17]  182         CALL    CLRSDA
   2095                     183 AHEAD:
   2095 CD 28 20      [17]  184         CALL    SETSCL
   2098 CD 36 20      [17]  185         CALL    CLRSCL
   209B C9            [10]  186         RET
                            187         
                            188 ; I2C Write Byte routine
                            189 ; Takes A
                            190 ; Destroys B
                            191 ; Returns carry bit
   209C                     192 I2CWBYTE:
   209C 06 08         [ 7]  193         LD      B,8
   209E                     194 ILOOP:
   209E C5            [11]  195         PUSH    BC          ; save B
   209F CB 07         [ 8]  196         RLC     A    
   20A1 F5            [11]  197         PUSH    AF          ; save A
   20A2 CD 8B 20      [17]  198         CALL    I2CWBIT
   20A5 F1            [10]  199         POP     AF
   20A6 C1            [10]  200         POP     BC
   20A7 10 F5         [13]  201         DJNZ    ILOOP
   20A9 CD 7C 20      [17]  202         CALL    I2CRBIT
   20AC C9            [10]  203         RET
                            204 
                            205 ; I2C Read Byte routine
                            206 ; Destroys BC
                            207 ; Returns A
   20AD                     208 I2CRBYTE:
   20AD 06 08         [ 7]  209         LD      B,8
   20AF 0E 00         [ 7]  210         LD      C,0
   20B1                     211 LOOP3:
   20B1 C5            [11]  212         PUSH    BC
   20B2 CD 7C 20      [17]  213         CALL    I2CRBIT     ; get bit in carry flag
   20B5 C1            [10]  214         POP     BC
   20B6 CB 11         [ 8]  215         RL      C           ; rotate carry into bit0 of C register
   20B8 10 F7         [13]  216         DJNZ    LOOP3
   20BA AF            [ 4]  217         XOR     A           ; clear carry flag              
   20BB C5            [11]  218         PUSH    BC
   20BC CD 8B 20      [17]  219         CALL    I2CWBIT
   20BF C1            [10]  220         POP     BC
   20C0 79            [ 4]  221         LD      A,C
   20C1 C9            [10]  222         RET
                            223 ;
                            224 
                            225 ; Read 4-byte I2C Command from device into CMDBUF
                            226 ; Uses HL
                            227 ; Destroys A,BC,HL
   20C2                     228 I2CRREQ:
   20C2 CD 6B 20      [17]  229         CALL    I2CSTART
   20C5 3E 11         [ 7]  230         LD      A,I2CRADR
   20C7 CD 9C 20      [17]  231         CALL    I2CWBYTE
   20CA 38 1A         [12]  232         JR      C,SKIP
   20CC CD AD 20      [17]  233         CALL    I2CRBYTE
   20CF DD 77 00      [19]  234         LD      (IX),A
   20D2 CD AD 20      [17]  235         CALL    I2CRBYTE
   20D5 DD 77 01      [19]  236         LD      (IX+1),A  
   20D8 CD AD 20      [17]  237         CALL    I2CRBYTE
   20DB DD 77 02      [19]  238         LD      (IX+2),A
   20DE CD AD 20      [17]  239         CALL    I2CRBYTE
   20E1 DD 77 03      [19]  240         LD      (IX+3),A
   20E4 18 14         [12]  241         JR      ENDI2C
                            242     
   20E6                     243 SKIP:                       ; If no device present, fake an idle response
   20E6 3E 2E         [ 7]  244         LD      A,0x2e  ; '.'
   20E8 DD 77 00      [19]  245         LD      (IX),A
   20EB 18 0D         [12]  246         JR      ENDI2C
                            247 
   20ED                     248 I2CSRESP:
   20ED F5            [11]  249         PUSH    AF
   20EE CD 6B 20      [17]  250         CALL    I2CSTART
   20F1 3E 10         [ 7]  251         LD      A,I2CWADR
   20F3 CD 9C 20      [17]  252         CALL    I2CWBYTE
   20F6 F1            [10]  253         POP     AF
   20F7 CD 9C 20      [17]  254         CALL    I2CWBYTE
   20FA                     255 ENDI2C:
   20FA CD 72 20      [17]  256         CALL    I2CSTOP
   20FD C9            [10]  257         RET
                            258 ;
                            259 
                            260 ; Main Polling loop
                            261 ; Return carry flag if we got a valid command (not idle)
   20FE                     262 POLL:
   20FE CD C2 20      [17]  263         CALL    I2CRREQ
   2101 DD 7E 00      [19]  264         LD      A,(IX)
   2104 FE 52         [ 7]  265         CP      0x52    ; 'R' - Read memory
   2106 28 1B         [12]  266         JR      Z,MREAD
   2108 FE 57         [ 7]  267         CP      0x57    ; 'W' - Write memory
   210A 28 1D         [12]  268         JR      Z,MWRITE
   210C FE 49         [ 7]  269         CP      0x49    ; 'I' - Input from port
   210E 28 2D         [12]  270         JR      Z,PREAD
   2110 FE 4F         [ 7]  271         CP      0x4F    ; 'O' - Output from port
   2112 28 30         [12]  272         JR      Z,PWRITE
   2114 FE 43         [ 7]  273         CP      0x43    ; 'C' - Call subroutine
   2116 28 3B         [12]  274         JR      Z,REMCALL
   2118 3F            [ 4]  275         CCF
   2119 C9            [10]  276         RET
   211A                     277 LOADHL:
   211A DD 7E 01      [19]  278         LD      A,(IX+1)
   211D 67            [ 4]  279         LD      H,A
   211E DD 7E 02      [19]  280         LD      A,(IX+2)
   2121 6F            [ 4]  281         LD      L,A
   2122 C9            [10]  282         RET    
   2123                     283 MREAD:
   2123 CD 34 21      [17]  284         CALL    LOADBC
   2126 0A            [ 7]  285         LD      A,(BC)
   2127 18 25         [12]  286         JR      SRESP
   2129                     287 MWRITE:
   2129 CD 34 21      [17]  288         CALL    LOADBC
   212C DD 7E 03      [19]  289         LD      A,(IX+3)
   212F 02            [ 7]  290         LD      (BC),A
   2130 3E 57         [ 7]  291         LD      A,0x57  ;'W'
   2132 18 1A         [12]  292         JR      SRESP
   2134                     293 LOADBC:
   2134 DD 7E 01      [19]  294         LD      A,(IX+1)
   2137 47            [ 4]  295         LD      B,A
   2138 DD 7E 02      [19]  296         LD      A,(IX+2)
   213B 4F            [ 4]  297         LD      C,A
   213C C9            [10]  298         RET
   213D                     299 PREAD:
   213D CD 34 21      [17]  300         CALL    LOADBC
   2140 ED 78         [12]  301         IN      A,(C)
   2142 18 0A         [12]  302         JR      SRESP
   2144                     303 PWRITE:
   2144 CD 34 21      [17]  304         CALL    LOADBC
   2147 DD 7E 03      [19]  305         LD      A,(IX+3)
   214A ED 79         [12]  306         OUT     (C),A
   214C 3E 4F         [ 7]  307         LD      A,0x4F  ;'O'
   214E                     308 SRESP:
   214E CD ED 20      [17]  309         CALL    I2CSRESP
   2151                     310 RHERE:
   2151 37            [ 4]  311         SCF
   2152 C9            [10]  312         RET
   2153                     313 REMCALL:
   2153 21 5B 21      [10]  314         LD      HL,START
   2156 E5            [11]  315         PUSH    HL
   2157 CD 1A 21      [17]  316         CALL    LOADHL
   215A E9            [ 4]  317         JP      (HL)
                            318     
   215B                     319 START:
                            320 	;DI
                            321         ;LD      SP,SSTACK   ; have to set valid SP
   215B DD 21 CE 4F   [14]  322         LD      IX,CMDBUF   ; Easy to index command buffer
                            323         
                            324 ; Main routine
   215F                     325 MAIN:
   215F DB 10         [11]  326 	IN	A,(0x10)    ; hit watchdog
   2161 CD FE 20      [17]  327         CALL    POLL
   2164 38 F9         [12]  328         JR      C,MAIN
                            329         
   2166 01 80 01      [10]  330         LD      BC,BIGDEL
   2169                     331 MLOOP:
   2169 0B            [ 6]  332         DEC     BC
   216A 79            [ 4]  333         LD      A,C
   216B B0            [ 4]  334         OR      B
   216C 20 FB         [12]  335         JR      NZ,MLOOP
   216E 18 EF         [12]  336         JR      MAIN
                            337 
                            338 
                            339     
                            340 
