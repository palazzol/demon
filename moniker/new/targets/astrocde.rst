                              2 
                              3 ;--------------------------------------------------------------------------
                              4 ; TARGET-SPECIFIC DEFINITIONS
                              5 ;--------------------------------------------------------------------------
                              6 ; RAM SETTINGS
                     4FCE     7 RAMADDR .equ    0x4fce      ; Start of RAM variables - need only 4 bytes here, but we have 16
                              8                             ; Stack will grow towards 0 from this point
                              9 
                             10 ;--------------------------------------------------------------------------
                             11 ; MESSAGE MACRO
                             12 ;--------------------------------------------------------------------------
                             13         .macro  MESSAGE_MACRO
                             14         .ascii	"DEMON DEBUGGER"
                             15         .byte	0x00
                             16         .endm
                             17 
                             18 ;--------------------------------------------------------------------------
                             19 ; STARTUP MACROS
                             20 ;
                             21 ; These are called once, and can be used do any target-specific
                             22 ; initialization that is required
                             23 ;--------------------------------------------------------------------------
                             24 
                             25         .macro  STARTUP1_MACRO 
                             26         ; We are relying on the console to do this initialization 
                             27         ;DI
                             28         ;LD      SP,RAMADDR   ; have to set valid SP
                             29         .endm     
                             30 
                             31 ;--------------------------------------------------------------------------
                             32 ; EVERY MACRO
                             33 ; This is called regularly, every polling loop, and can be used do any 
                             34 ; target-specific task that is required, such as hitting a watchdog
                             35 ;--------------------------------------------------------------------------
                             36 
                             37         .macro  EVERY_MACRO  
                             38         IN	A,(0x10)    ; hit watchdog
                             39         RET
                             40         .endm        
                             41 
                             42 ;--------------------------------------------------------------------------
                             43 ; ROM TEMPLATE - this defines the rom layout, and which kind of io
                             44 ;--------------------------------------------------------------------------
                             45         .include "../rom_templates/astrocde-cart_romio_2000_2k.asm"
                              1 
                              2          
                     2000     3 STRTADD .equ    0x2000      ; start of chip memory mapping
                     0800     4 ROMSIZE .equ    0x0800      ; 2K ROM 
                              5 
                              6         .include "../dd/dd.def"
                              1 
                     2800     2 ROMEND  .equ    STRTADD+ROMSIZE
                              3 
                              4 
                              7         .include "../io/romio.def"
                              1 ; For Demon Debugger Hardware - Rev D 
                              2 
                     27A0     3 IOREGR   .equ   STRTADD+0x07a0    ;reserved region for IO READ
                     27C0     4 IOREGW   .equ   STRTADD+0x07c0    ;reserved region for IO WRITE
                              5 
                     27A0     6 IOADD    .equ   IOREGR            ;start of region
                     27E0     7 IOEND    .equ   STRTADD+0x07e0    ;end of region
                              8 
                              9 ; TIMER SETTING
                     0180    10 BIGDEL  .equ    0x0180      ; delay factor
                             11 
                             12         ;--------------------------------------------------
                             13         ; On the Astrocade, the start address is 0x2000
                             14         ;--------------------------------------------------
                             15         .bank   first   (base=STRTADD, size=IOADD-STRTADD)
                             16         .area   first   (ABS, BANK=first)
                             17 
   2000 55                   18         .byte   0x55	    ; cartridge header
   2001 18 02                19         .word   0x0218	    ; next menu item (first one)
   2003 19 20                20         .word   TITLE	    ; title pointer
   2005 28 20                21         .word   STARTUP1	; start pointer
                             22         
   2007 C9            [10]   23         ret		    ; rst8
   2008 00            [ 4]   24         nop
   2009 00            [ 4]   25         nop
                             26 
   200A C9            [10]   27         ret		    ; rst16
   200B 00            [ 4]   28         nop
   200C 00            [ 4]   29         nop
                             30         
   200D C9            [10]   31         ret		    ; rst24
   200E 00            [ 4]   32         nop
   200F 00            [ 4]   33         nop
                             34         
   2010 C9            [10]   35         ret		    ; rst32
   2011 00            [ 4]   36         nop
   2012 00            [ 4]   37         nop
                             38         
   2013 C9            [10]   39         ret		    ; rst40
   2014 00            [ 4]   40         nop
   2015 00            [ 4]   41         nop
                             42         
   2016 C9            [10]   43         ret		    ; rst48
   2017 00            [ 4]   44         nop
   2018 00            [ 4]   45         nop
                             46 
   2019                      47 TITLE:	
   0019                      48         MESSAGE_MACRO
   2019 44 45 4D 4F 4E 20     1         .ascii	"DEMON DEBUGGER"
        44 45 42 55 47 47
        45 52
   2027 00                    2         .byte	0x00
                             49     	
   2028                      50 STARTUP1:  
   0028                      51         STARTUP1_MACRO
                              1         ; We are relying on the console to do this initialization 
                              2         ;DI
                              3         ;LD      SP,RAMADDR   ; have to set valid SP
                             52 
                             53         ; Entry to main routine here
                             54         .include "../dd/z80_main.asm"
                              1 ; I2C ADDRESSING
                     0011     2 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010     3 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                              4 
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 ; RAM Variables	
                              7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              8 
                     4FCE     9 CMDBUF  .equ    RAMADDR     ; Need only 4 bytes of ram for command buffer
                             10 
   2028 DD 21 CE 4F   [14]   11         LD      IX,CMDBUF   ; Easy to index command buffer
   202C 16 00         [ 7]   12         LD      D,#0x00     ; initialize D to prevent index overflow
                             13 
                             14 ; Main routine
   202E                      15 MAIN:
   202E CD 34 21      [17]   16         CALL    EVERY
   2031 CD D7 20      [17]   17         CALL    POLL
   2034 DA 2E 20      [10]   18         JP      C,MAIN
                             19         
   2037 01 80 01      [10]   20         LD      BC,BIGDEL
   203A                      21 DLOOP:
   203A 0B            [ 6]   22         DEC     BC
   203B 79            [ 4]   23         LD      A,C
   203C B0            [ 4]   24         OR      B
   203D C2 3A 20      [10]   25         JP      NZ,DLOOP
   2040 C3 2E 20      [10]   26         JP      MAIN
                             27 
                             28 ; Delay for half a bit time
   2043                      29 I2CDELAY:
   2043 C9            [10]   30         RET     ; This is plenty
                             31 
                             32 ; I2C Start Condition
                             33 ; Uses HL
                             34 ; Destroys A
   2044                      35 I2CSTART:
   2044 CD 64 21      [17]   36         CALL    CLRSDA      
   2047 CD 47 21      [17]   37         CALL    CLRSCL
   204A C9            [10]   38         RET
                             39 
                             40 ; I2C Stop Condition
                             41 ; Uses HL
                             42 ; Destroys A
   204B                      43 I2CSTOP:
   204B CD 64 21      [17]   44         CALL    CLRSDA
   204E CD 37 21      [17]   45         CALL    SETSCL
   2051 CD 54 21      [17]   46         CALL    SETSDA
   2054 C9            [10]   47         RET
                             48 
                             49 ; I2C Read Bit routine
                             50 ; Returns bit in carry blag
                             51 ; Destroys A
   2055                      52 I2CRBIT:
   2055 CD 54 21      [17]   53         CALL    SETSDA
   2058 CD 37 21      [17]   54         CALL    SETSCL
   205B CD 74 21      [17]   55         CALL    READSDA
   205E F5            [11]   56         PUSH    AF          ; save carry flag
   205F CD 47 21      [17]   57         CALL    CLRSCL
   2062 F1            [10]   58         POP     AF          ; rv in carry flag
   2063 C9            [10]   59         RET
                             60 
                             61 ; I2C Write Bit routine
                             62 ; Takes carry flag
                             63 ; Destroys A
   2064                      64 I2CWBIT:
   2064 30 05         [12]   65         JR      NC,DOCLR
   2066 CD 54 21      [17]   66         CALL    SETSDA
   2069 18 03         [12]   67         JR      AHEAD
   206B                      68 DOCLR:
   206B CD 64 21      [17]   69         CALL    CLRSDA
   206E                      70 AHEAD:
   206E CD 37 21      [17]   71         CALL    SETSCL
   2071 CD 47 21      [17]   72         CALL    CLRSCL
   2074 C9            [10]   73         RET
                             74 
                             75 ; I2C Write Byte routine
                             76 ; Takes A
                             77 ; Destroys B
                             78 ; Returns carry bit
   2075                      79 I2CWBYTE:
   2075 06 08         [ 7]   80         LD      B,8
   2077                      81 ILOOP:
   2077 C5            [11]   82         PUSH    BC          ; save B
   2078 CB 07         [ 8]   83         RLC     A    
   207A F5            [11]   84         PUSH    AF          ; save A
   207B CD 64 20      [17]   85         CALL    I2CWBIT
   207E F1            [10]   86         POP     AF
   207F C1            [10]   87         POP     BC
   2080 10 F5         [13]   88         DJNZ    ILOOP
   2082 CD 55 20      [17]   89         CALL    I2CRBIT
   2085 C9            [10]   90         RET
                             91 
                             92 ; I2C Read Byte routine
                             93 ; Destroys BC
                             94 ; Returns A
   2086                      95 I2CRBYTE:
   2086 06 08         [ 7]   96         LD      B,8
   2088 0E 00         [ 7]   97         LD      C,0
   208A                      98 LOOP3:
   208A C5            [11]   99         PUSH    BC
   208B CD 55 20      [17]  100         CALL    I2CRBIT     ; get bit in carry flag
   208E C1            [10]  101         POP     BC
   208F CB 11         [ 8]  102         RL      C           ; rotate carry into bit0 of C register
   2091 10 F7         [13]  103         DJNZ    LOOP3
   2093 AF            [ 4]  104         XOR     A           ; clear carry flag              
   2094 C5            [11]  105         PUSH    BC
   2095 CD 64 20      [17]  106         CALL    I2CWBIT
   2098 C1            [10]  107         POP     BC
   2099 79            [ 4]  108         LD      A,C
   209A C9            [10]  109         RET
                            110 ;
                            111 
                            112 ; Read 4-byte I2C Command from device into CMDBUF
                            113 ; Uses HL
                            114 ; Destroys A,BC,HL
   209B                     115 I2CRREQ:
   209B CD 44 20      [17]  116         CALL    I2CSTART
   209E 3E 11         [ 7]  117         LD      A,I2CRADR
   20A0 CD 75 20      [17]  118         CALL    I2CWBYTE
   20A3 38 1A         [12]  119         JR      C,SKIP
   20A5 CD 86 20      [17]  120         CALL    I2CRBYTE
   20A8 DD 77 00      [19]  121         LD      (IX),A
   20AB CD 86 20      [17]  122         CALL    I2CRBYTE
   20AE DD 77 01      [19]  123         LD      (IX+1),A  
   20B1 CD 86 20      [17]  124         CALL    I2CRBYTE
   20B4 DD 77 02      [19]  125         LD      (IX+2),A
   20B7 CD 86 20      [17]  126         CALL    I2CRBYTE
   20BA DD 77 03      [19]  127         LD      (IX+3),A
   20BD 18 14         [12]  128         JR      ENDI2C
                            129     
   20BF                     130 SKIP:                       ; If no device present, fake an idle response
   20BF 3E 2E         [ 7]  131         LD      A,0x2e  ; '.'
   20C1 DD 77 00      [19]  132         LD      (IX),A
   20C4 18 0D         [12]  133         JR      ENDI2C
                            134 
   20C6                     135 I2CSRESP:
   20C6 F5            [11]  136         PUSH    AF
   20C7 CD 44 20      [17]  137         CALL    I2CSTART
   20CA 3E 10         [ 7]  138         LD      A,I2CWADR
   20CC CD 75 20      [17]  139         CALL    I2CWBYTE
   20CF F1            [10]  140         POP     AF
   20D0 CD 75 20      [17]  141         CALL    I2CWBYTE
   20D3                     142 ENDI2C:
   20D3 CD 4B 20      [17]  143         CALL    I2CSTOP
   20D6 C9            [10]  144         RET
                            145 ;
                            146 
                            147 ; Main Polling loop
                            148 ; Return carry flag if we got a valid command (not idle)
   20D7                     149 POLL:
   20D7 CD 9B 20      [17]  150         CALL    I2CRREQ
   20DA DD 7E 00      [19]  151         LD      A,(IX)
   20DD FE 52         [ 7]  152         CP      0x52    ; 'R' - Read memory
   20DF 28 1B         [12]  153         JR      Z,MREAD
   20E1 FE 57         [ 7]  154         CP      0x57    ; 'W' - Write memory
   20E3 28 1D         [12]  155         JR      Z,MWRITE
   20E5 FE 49         [ 7]  156         CP      0x49    ; 'I' - Input from port
   20E7 28 2D         [12]  157         JR      Z,PREAD
   20E9 FE 4F         [ 7]  158         CP      0x4F    ; 'O' - Output from port
   20EB 28 30         [12]  159         JR      Z,PWRITE
   20ED FE 43         [ 7]  160         CP      0x43    ; 'C' - Call subroutine
   20EF 28 3B         [12]  161         JR      Z,REMCALL
   20F1 3F            [ 4]  162         CCF
   20F2 C9            [10]  163         RET
   20F3                     164 LOADHL:
   20F3 DD 7E 01      [19]  165         LD      A,(IX+1)
   20F6 67            [ 4]  166         LD      H,A
   20F7 DD 7E 02      [19]  167         LD      A,(IX+2)
   20FA 6F            [ 4]  168         LD      L,A
   20FB C9            [10]  169         RET    
   20FC                     170 MREAD:
   20FC CD 0D 21      [17]  171         CALL    LOADBC
   20FF 0A            [ 7]  172         LD      A,(BC)
   2100 18 25         [12]  173         JR      SRESP
   2102                     174 MWRITE:
   2102 CD 0D 21      [17]  175         CALL    LOADBC
   2105 DD 7E 03      [19]  176         LD      A,(IX+3)
   2108 02            [ 7]  177         LD      (BC),A
   2109 3E 57         [ 7]  178         LD      A,0x57  ;'W'
   210B 18 1A         [12]  179         JR      SRESP
   210D                     180 LOADBC:
   210D DD 7E 01      [19]  181         LD      A,(IX+1)
   2110 47            [ 4]  182         LD      B,A
   2111 DD 7E 02      [19]  183         LD      A,(IX+2)
   2114 4F            [ 4]  184         LD      C,A
   2115 C9            [10]  185         RET
   2116                     186 PREAD:
   2116 CD 0D 21      [17]  187         CALL    LOADBC
   2119 ED 78         [12]  188         IN      A,(C)
   211B 18 0A         [12]  189         JR      SRESP
   211D                     190 PWRITE:
   211D CD 0D 21      [17]  191         CALL    LOADBC
   2120 DD 7E 03      [19]  192         LD      A,(IX+3)
   2123 ED 79         [12]  193         OUT     (C),A
   2125 3E 4F         [ 7]  194         LD      A,0x4F  ;'O'
   2127                     195 SRESP:
   2127 CD C6 20      [17]  196         CALL    I2CSRESP
   212A                     197 RHERE:
   212A 37            [ 4]  198         SCF
   212B C9            [10]  199         RET
   212C                     200 REMCALL:
   212C 21 28 20      [10]  201         LD      HL,STARTUP1
   212F E5            [11]  202         PUSH    HL
   2130 CD F3 20      [17]  203         CALL    LOADHL
   2133 E9            [ 4]  204         JP      (HL)
                            205 
                             55 
   2134                      56 EVERY:
   0134                      57         EVERY_MACRO
   2134 DB 10         [11]    1         IN	A,(0x10)    ; hit watchdog
   2136 C9            [10]    2         RET
                             58 
                             59         ; Routines for romio here
                             60         .include "../io/z80_romio.asm"
                              1 
                              2 ; For Demon Debugger Hardware - Rev D 
                              3 
                              4 ; Set the SCL pin high
                              5 ; D is the global output buffer
                              6 ; Destroys A
   2137                       7 SETSCL:
   2137 7A            [ 4]    8         LD      A,D
   2138 F6 01         [ 7]    9         OR      0x01
   213A 57            [ 4]   10         LD      D,A
   213B E5            [11]   11         PUSH    HL
   213C 26 27         [ 7]   12         LD      H,#>IOREGW
   213E C6 C0         [ 7]   13         ADD     A,#<IOREGW 
   2140 6F            [ 4]   14         LD      L,A
   2141 7E            [ 7]   15         LD      A,(HL)
   2142 E1            [10]   16         POP     HL
   2143 CD 43 20      [17]   17         CALL    I2CDELAY
   2146 C9            [10]   18         RET
                             19     
                             20 ; Set the SCL pin low
                             21 ; D is the global output buffer
                             22 ; Destroys A
   2147                      23 CLRSCL:
   2147 7A            [ 4]   24         LD      A,D
   2148 E6 1E         [ 7]   25         AND     0x1E
   214A 57            [ 4]   26         LD      D,A
   214B E5            [11]   27         PUSH    HL
   214C 26 27         [ 7]   28         LD      H,#>IOREGW
   214E C6 C0         [ 7]   29         ADD     A,#<IOREGW 
   2150 6F            [ 4]   30         LD      L,A
   2151 7E            [ 7]   31         LD      A,(HL)
   2152 E1            [10]   32         POP     HL
   2153 C9            [10]   33         RET
                             34 
                             35 ; Set the DOUT pin low
                             36 ; D is the global output buffer
                             37 ; Destroys A 
   2154                      38 SETSDA:
   2154 7A            [ 4]   39         LD      A,D
   2155 E6 1D         [ 7]   40         AND     0x1D
   2157 57            [ 4]   41         LD      D,A
   2158 E5            [11]   42         PUSH    HL
   2159 26 27         [ 7]   43         LD      H,#>IOREGW
   215B C6 C0         [ 7]   44         ADD     A,#<IOREGW 
   215D 6F            [ 4]   45         LD      L,A
   215E 7E            [ 7]   46         LD      A,(HL)
   215F E1            [10]   47         POP     HL
   2160 CD 43 20      [17]   48         CALL    I2CDELAY
   2163 C9            [10]   49         RET
                             50 
                             51 ; Set the DOUT pin high
                             52 ; D is the global output buffer
                             53 ; Destroys A  
   2164                      54 CLRSDA:
   2164 7A            [ 4]   55         LD      A,D
   2165 F6 02         [ 7]   56         OR      0x02
   2167 57            [ 4]   57         LD      D,A
   2168 E5            [11]   58         PUSH    HL
   2169 26 27         [ 7]   59         LD      H,#>IOREGW
   216B C6 C0         [ 7]   60         ADD     A,#<IOREGW 
   216D 6F            [ 4]   61         LD      L,A
   216E 7E            [ 7]   62         LD      A,(HL)
   216F E1            [10]   63         POP     HL
   2170 CD 43 20      [17]   64         CALL    I2CDELAY
   2173 C9            [10]   65         RET
                             66 
                             67 ; Read the DIN pin 
                             68 ; returns bit in carry flag    
   2174                      69 READSDA:
   2174 7A            [ 4]   70         LD      A,D
   2175 E5            [11]   71         PUSH    HL
   2176 26 27         [ 7]   72         LD      H,#>IOREGR
   2178 C6 A0         [ 7]   73         ADD     A,#<IOREGR
   217A 6F            [ 4]   74         LD      L,A
   217B 7E            [ 7]   75         LD      A,(HL)
   217C E1            [10]   76         POP     HL
   217D CB 3F         [ 8]   77         SRL     A           ;carry flag
   217F C9            [10]   78         RET
                             61 
                             62         ;--------------------------------------------------
                             63         ; The romio region has a small table here
                             64         ;--------------------------------------------------
                             65         .bank   second  (base=IOADD, size=IOEND-IOADD)
                             66         .area   second  (ABS, BANK=second)
                             67         .include "../io/romio_table.asm"
                              1 
                              2 ; 
                              3 ; For Demon Debugger Hardware - Rev D 
                              4 ;
                              5 ; In earlier hardware designs, I tried to capture the address bus bits on a 
                              6 ; read cycle, to use to write to the Arduino.  But it turns out it is impossible
                              7 ; to know exactly when to sample these address bits across all platforms, designs, and 
                              8 ; clock speeds
                              9 ;
                             10 ; The solution I came up with was to make sure the data bus contains the same information
                             11 ; as the lower address bus during these read cycles, so that I can sample the data bus just like the 
                             12 ; CPU would.
                             13 ;
                             14 ; This block of memory, starting at 0x07c0, is filled with consecutive integers.
                             15 ; When the CPU reads from a location, the data bus matches the lower bits of the address bus.  
                             16 ; And the data bus read by the CPU is also written to the Arduino.
                             17 ; 
                             18 ; Note: Currently, only the bottom two bits are used, but reserving the memory
                             19 ; this way insures that up to 5 bits could be used 
                             20 ; 
                             21         ; ROMIO READ Area - reserved
   27A0 FF FF FF FF FF FF    22         .DB     0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
        FF FF FF FF FF FF
        FF FF FF FF
   27B0 FF FF FF FF FF FF    23         .DB     0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
        FF FF FF FF FF FF
        FF FF FF FF
                             24 
                             25         ; ROMIO WRITE Area - data is used
   27C0 00 01 02 03 04 05    26         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   27D0 10 11 12 13 14 15    27         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
                             28 
                             68 
                             69         ;--------------------------------------------------
                             70         ; There is a little more room here, which is unused
                             71         ;--------------------------------------------------
                             72         .bank   third  (base=IOREGW+0x20, size=ROMEND-IOEND)
                             73         .area   third  (ABS, BANK=third)
                             74 
                             75         .end
