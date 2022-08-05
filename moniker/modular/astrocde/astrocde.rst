                              1 
                              2         .include "settings.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; You will need to adjust these variables for different targets
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                              5 ; RAM SETTINGS
                              6 
                     4FCE     7 RAMADDR .equ    0x4fce      ; Start of RAM variables - need only 4 bytes here, but we have 16
                              8 
                              9 ; ROM SETTINGS - usually the first 2K of memory for z80
                             10 
                     2000    11 STRTADD .equ    0x2000      ; start of chip memory mapping
                             12 
                             13 ; TIMER SETTING
                     0180    14 BIGDEL  .equ    0x0180      ; delay factor
                             15 
                             16 ; I2C ADDRESSING
                     0011    17 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    18 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                              3         .include "../romio/defs.asm"
                              1 ; For Demon Debugger Hardware - Rev D 
                              2 
                     27A0     3 IOREGR   .equ   STRTADD+0x07a0    ;reserved region for IO READ
                     27C0     4 IOREGW   .equ   STRTADD+0x07c0    ;reserved region for IO WRITE
                              5 
                     27A0     6 IOADD    .equ   IOREGR            ;start of region
                              4 
                              5         ; This section must end before the IO Region
                              6         .bank   first   (base=STRTADD, size=IOADD-STRTADD)
                              7         .area   first   (ABS, BANK=first)
                              8 
                              9         .include "cartheader.asm" 
   2000 55                    1         .byte   0x55	    ; cartridge header
   2001 18 02                 2         .word   0x0218	    ; next menu item (first one)
   2003 19 20                 3         .word   TITLE	    ; title pointer
   2005 62 21                 4         .word   START	    ; start pointer
                              5         
   2007 C9            [10]    6         ret		    ; rst8
   2008 00            [ 4]    7         nop
   2009 00            [ 4]    8         nop
                              9 
   200A C9            [10]   10         ret		    ; rst16
   200B 00            [ 4]   11         nop
   200C 00            [ 4]   12         nop
                             13         
   200D C9            [10]   14         ret		    ; rst24
   200E 00            [ 4]   15         nop
   200F 00            [ 4]   16         nop
                             17         
   2010 C9            [10]   18         ret		    ; rst32
   2011 00            [ 4]   19         nop
   2012 00            [ 4]   20         nop
                             21         
   2013 C9            [10]   22         ret		    ; rst40
   2014 00            [ 4]   23         nop
   2015 00            [ 4]   24         nop
                             25         
   2016 C9            [10]   26         ret		    ; rst48
   2017 00            [ 4]   27         nop
   2018 00            [ 4]   28         nop
                             29 
   2019 44 45 4D 4F 4E 20    30 TITLE:	.ascii	"DEMON DEBUGGER"
        44 45 42 55 47 47
        45 52
   2027 00                   31         .byte	0x00
                             10 
                             11         .include "../z80/romio.asm" 
                              1 
                              2 ; For Demon Debugger Hardware - Rev D 
                              3 
                              4 ; Set the SCL pin high
                              5 ; D is the global output buffer
                              6 ; Destroys A
   2028                       7 SETSCL:
   2028 7A            [ 4]    8         LD      A,D
   2029 F6 01         [ 7]    9         OR      0x01
   202B 57            [ 4]   10         LD      D,A
   202C E5            [11]   11         PUSH    HL
   202D 26 27         [ 7]   12         LD      H,#>IOREGW
   202F C6 C0         [ 7]   13         ADD     A,#<IOREGW 
   2031 6F            [ 4]   14         LD      L,A
   2032 7E            [ 7]   15         LD      A,(HL)
   2033 E1            [10]   16         POP     HL
   2034 CD 71 20      [17]   17         CALL    I2CDELAY
   2037 C9            [10]   18         RET
                             19     
                             20 ; Set the SCL pin low
                             21 ; D is the global output buffer
                             22 ; Destroys A
   2038                      23 CLRSCL:
   2038 7A            [ 4]   24         LD      A,D
   2039 E6 1E         [ 7]   25         AND     0x1E
   203B 57            [ 4]   26         LD      D,A
   203C E5            [11]   27         PUSH    HL
   203D 26 27         [ 7]   28         LD      H,#>IOREGW
   203F C6 C0         [ 7]   29         ADD     A,#<IOREGW 
   2041 6F            [ 4]   30         LD      L,A
   2042 7E            [ 7]   31         LD      A,(HL)
   2043 E1            [10]   32         POP     HL
   2044 C9            [10]   33         RET
                             34 
                             35 ; Set the DOUT pin low
                             36 ; D is the global output buffer
                             37 ; Destroys A 
   2045                      38 SETSDA:
   2045 7A            [ 4]   39         LD      A,D
   2046 E6 1D         [ 7]   40         AND     0x1D
   2048 57            [ 4]   41         LD      D,A
   2049 E5            [11]   42         PUSH    HL
   204A 26 27         [ 7]   43         LD      H,#>IOREGW
   204C C6 C0         [ 7]   44         ADD     A,#<IOREGW 
   204E 6F            [ 4]   45         LD      L,A
   204F 7E            [ 7]   46         LD      A,(HL)
   2050 E1            [10]   47         POP     HL
   2051 CD 71 20      [17]   48         CALL    I2CDELAY
   2054 C9            [10]   49         RET
                             50 
                             51 ; Set the DOUT pin high
                             52 ; D is the global output buffer
                             53 ; Destroys A  
   2055                      54 CLRSDA:
   2055 7A            [ 4]   55         LD      A,D
   2056 F6 02         [ 7]   56         OR      0x02
   2058 57            [ 4]   57         LD      D,A
   2059 E5            [11]   58         PUSH    HL
   205A 26 27         [ 7]   59         LD      H,#>IOREGW
   205C C6 C0         [ 7]   60         ADD     A,#<IOREGW 
   205E 6F            [ 4]   61         LD      L,A
   205F 7E            [ 7]   62         LD      A,(HL)
   2060 E1            [10]   63         POP     HL
   2061 CD 71 20      [17]   64         CALL    I2CDELAY
   2064 C9            [10]   65         RET
                             66 
                             67 ; Read the DIN pin 
                             68 ; returns bit in carry flag    
   2065                      69 READSDA:
   2065 7A            [ 4]   70         LD      A,D
   2066 E5            [11]   71         PUSH    HL
   2067 26 27         [ 7]   72         LD      H,#>IOREGR
   2069 C6 A0         [ 7]   73         ADD     A,#<IOREGR
   206B 6F            [ 4]   74         LD      L,A
   206C 7E            [ 7]   75         LD      A,(HL)
   206D E1            [10]   76         POP     HL
   206E CB 3F         [ 8]   77         SRL     A           ;carry flag
   2070 C9            [10]   78         RET
                             12         .include "mainloop.asm"
                              1 
                              2 ; Delay for half a bit time
   2071                       3 I2CDELAY:
   2071 C9            [10]    4         RET     ; This is plenty
                              5 
                              6 ; I2C Start Condition
                              7 ; Uses HL
                              8 ; Destroys A
   2072                       9 I2CSTART:
   2072 CD 55 20      [17]   10         CALL    CLRSDA      
   2075 CD 38 20      [17]   11         CALL    CLRSCL
   2078 C9            [10]   12         RET
                             13 
                             14 ; I2C Stop Condition
                             15 ; Uses HL
                             16 ; Destroys A
   2079                      17 I2CSTOP:
   2079 CD 55 20      [17]   18         CALL    CLRSDA
   207C CD 28 20      [17]   19         CALL    SETSCL
   207F CD 45 20      [17]   20         CALL    SETSDA
   2082 C9            [10]   21         RET
                             22 
                             23 ; I2C Read Bit routine
                             24 ; Returns bit in carry blag
                             25 ; Destroys A
   2083                      26 I2CRBIT:
   2083 CD 45 20      [17]   27         CALL    SETSDA
   2086 CD 28 20      [17]   28         CALL    SETSCL
   2089 CD 65 20      [17]   29         CALL    READSDA
   208C F5            [11]   30         PUSH    AF          ; save carry flag
   208D CD 38 20      [17]   31         CALL    CLRSCL
   2090 F1            [10]   32         POP     AF          ; rv in carry flag
   2091 C9            [10]   33         RET
                             34 
                             35 ; I2C Write Bit routine
                             36 ; Takes carry flag
                             37 ; Destroys A
   2092                      38 I2CWBIT:
   2092 30 05         [12]   39         JR      NC,DOCLR
   2094 CD 45 20      [17]   40         CALL    SETSDA
   2097 18 03         [12]   41         JR      AHEAD
   2099                      42 DOCLR:
   2099 CD 55 20      [17]   43         CALL    CLRSDA
   209C                      44 AHEAD:
   209C CD 28 20      [17]   45         CALL    SETSCL
   209F CD 38 20      [17]   46         CALL    CLRSCL
   20A2 C9            [10]   47         RET
                             48         
                             49 ; I2C Write Byte routine
                             50 ; Takes A
                             51 ; Destroys B
                             52 ; Returns carry bit
   20A3                      53 I2CWBYTE:
   20A3 06 08         [ 7]   54         LD      B,8
   20A5                      55 ILOOP:
   20A5 C5            [11]   56         PUSH    BC          ; save B
   20A6 CB 07         [ 8]   57         RLC     A    
   20A8 F5            [11]   58         PUSH    AF          ; save A
   20A9 CD 92 20      [17]   59         CALL    I2CWBIT
   20AC F1            [10]   60         POP     AF
   20AD C1            [10]   61         POP     BC
   20AE 10 F5         [13]   62         DJNZ    ILOOP
   20B0 CD 83 20      [17]   63         CALL    I2CRBIT
   20B3 C9            [10]   64         RET
                             65 
                             66 ; I2C Read Byte routine
                             67 ; Destroys BC
                             68 ; Returns A
   20B4                      69 I2CRBYTE:
   20B4 06 08         [ 7]   70         LD      B,8
   20B6 0E 00         [ 7]   71         LD      C,0
   20B8                      72 LOOP3:
   20B8 C5            [11]   73         PUSH    BC
   20B9 CD 83 20      [17]   74         CALL    I2CRBIT     ; get bit in carry flag
   20BC C1            [10]   75         POP     BC
   20BD CB 11         [ 8]   76         RL      C           ; rotate carry into bit0 of C register
   20BF 10 F7         [13]   77         DJNZ    LOOP3
   20C1 AF            [ 4]   78         XOR     A           ; clear carry flag              
   20C2 C5            [11]   79         PUSH    BC
   20C3 CD 92 20      [17]   80         CALL    I2CWBIT
   20C6 C1            [10]   81         POP     BC
   20C7 79            [ 4]   82         LD      A,C
   20C8 C9            [10]   83         RET
                             84 ;
                             85 
                             86 ; Read 4-byte I2C Command from device into CMDBUF
                             87 ; Uses HL
                             88 ; Destroys A,BC,HL
   20C9                      89 I2CRREQ:
   20C9 CD 72 20      [17]   90         CALL    I2CSTART
   20CC 3E 11         [ 7]   91         LD      A,I2CRADR
   20CE CD A3 20      [17]   92         CALL    I2CWBYTE
   20D1 38 1A         [12]   93         JR      C,SKIP
   20D3 CD B4 20      [17]   94         CALL    I2CRBYTE
   20D6 DD 77 00      [19]   95         LD      (IX),A
   20D9 CD B4 20      [17]   96         CALL    I2CRBYTE
   20DC DD 77 01      [19]   97         LD      (IX+1),A  
   20DF CD B4 20      [17]   98         CALL    I2CRBYTE
   20E2 DD 77 02      [19]   99         LD      (IX+2),A
   20E5 CD B4 20      [17]  100         CALL    I2CRBYTE
   20E8 DD 77 03      [19]  101         LD      (IX+3),A
   20EB 18 14         [12]  102         JR      ENDI2C
                            103     
   20ED                     104 SKIP:                       ; If no device present, fake an idle response
   20ED 3E 2E         [ 7]  105         LD      A,0x2e  ; '.'
   20EF DD 77 00      [19]  106         LD      (IX),A
   20F2 18 0D         [12]  107         JR      ENDI2C
                            108 
   20F4                     109 I2CSRESP:
   20F4 F5            [11]  110         PUSH    AF
   20F5 CD 72 20      [17]  111         CALL    I2CSTART
   20F8 3E 10         [ 7]  112         LD      A,I2CWADR
   20FA CD A3 20      [17]  113         CALL    I2CWBYTE
   20FD F1            [10]  114         POP     AF
   20FE CD A3 20      [17]  115         CALL    I2CWBYTE
   2101                     116 ENDI2C:
   2101 CD 79 20      [17]  117         CALL    I2CSTOP
   2104 C9            [10]  118         RET
                            119 ;
                            120 
                            121 ; Main Polling loop
                            122 ; Return carry flag if we got a valid command (not idle)
   2105                     123 POLL:
   2105 CD C9 20      [17]  124         CALL    I2CRREQ
   2108 DD 7E 00      [19]  125         LD      A,(IX)
   210B FE 52         [ 7]  126         CP      0x52    ; 'R' - Read memory
   210D 28 1B         [12]  127         JR      Z,MREAD
   210F FE 57         [ 7]  128         CP      0x57    ; 'W' - Write memory
   2111 28 1D         [12]  129         JR      Z,MWRITE
   2113 FE 49         [ 7]  130         CP      0x49    ; 'I' - Input from port
   2115 28 2D         [12]  131         JR      Z,PREAD
   2117 FE 4F         [ 7]  132         CP      0x4F    ; 'O' - Output from port
   2119 28 30         [12]  133         JR      Z,PWRITE
   211B FE 43         [ 7]  134         CP      0x43    ; 'C' - Call subroutine
   211D 28 3B         [12]  135         JR      Z,REMCALL
   211F 3F            [ 4]  136         CCF
   2120 C9            [10]  137         RET
   2121                     138 LOADHL:
   2121 DD 7E 01      [19]  139         LD      A,(IX+1)
   2124 67            [ 4]  140         LD      H,A
   2125 DD 7E 02      [19]  141         LD      A,(IX+2)
   2128 6F            [ 4]  142         LD      L,A
   2129 C9            [10]  143         RET    
   212A                     144 MREAD:
   212A CD 3B 21      [17]  145         CALL    LOADBC
   212D 0A            [ 7]  146         LD      A,(BC)
   212E 18 25         [12]  147         JR      SRESP
   2130                     148 MWRITE:
   2130 CD 3B 21      [17]  149         CALL    LOADBC
   2133 DD 7E 03      [19]  150         LD      A,(IX+3)
   2136 02            [ 7]  151         LD      (BC),A
   2137 3E 57         [ 7]  152         LD      A,0x57  ;'W'
   2139 18 1A         [12]  153         JR      SRESP
   213B                     154 LOADBC:
   213B DD 7E 01      [19]  155         LD      A,(IX+1)
   213E 47            [ 4]  156         LD      B,A
   213F DD 7E 02      [19]  157         LD      A,(IX+2)
   2142 4F            [ 4]  158         LD      C,A
   2143 C9            [10]  159         RET
   2144                     160 PREAD:
   2144 CD 3B 21      [17]  161         CALL    LOADBC
   2147 ED 78         [12]  162         IN      A,(C)
   2149 18 0A         [12]  163         JR      SRESP
   214B                     164 PWRITE:
   214B CD 3B 21      [17]  165         CALL    LOADBC
   214E DD 7E 03      [19]  166         LD      A,(IX+3)
   2151 ED 79         [12]  167         OUT     (C),A
   2153 3E 4F         [ 7]  168         LD      A,0x4F  ;'O'
   2155                     169 SRESP:
   2155 CD F4 20      [17]  170         CALL    I2CSRESP
   2158                     171 RHERE:
   2158 37            [ 4]  172         SCF
   2159 C9            [10]  173         RET
   215A                     174 REMCALL:
   215A 21 62 21      [10]  175         LD      HL,START
   215D E5            [11]  176         PUSH    HL
   215E CD 21 21      [17]  177         CALL    LOADHL
   2161 E9            [ 4]  178         JP      (HL)
                            179     
   2162                     180 START:
                            181         ;DI
                            182         ;LD      SP,SSTACK   ; have to set valid SP
   2162 DD 21 CE 4F   [14]  183         LD      IX,RAMADDR   ; Easy to index command buffer
                            184         
                            185 ; Main routine
   2166                     186 MAIN:
   2166 DB 10         [11]  187         IN	A,(0x10)    ; hit watchdog
   2168 CD 05 21      [17]  188         CALL    POLL
   216B 38 F9         [12]  189         JR      C,MAIN
                            190         
   216D 01 80 01      [10]  191         LD      BC,BIGDEL
   2170                     192 MLOOP:
   2170 0B            [ 6]  193         DEC     BC
   2171 79            [ 4]  194         LD      A,C
   2172 B0            [ 4]  195         OR      B
   2173 20 FB         [12]  196         JR      NZ,MLOOP
   2175 18 EF         [12]  197         JR      MAIN
                            198 
                            199 
                            200     
                            201 
                             13         
                             14         .include "../romio/table.asm"
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
                             21         .bank   iowritebank   (base=IOREGW, size=0x20)
                             22         .area   iowritearea   (ABS, BANK=iowritebank)
                             23 
   27C0 00 01 02 03 04 05    24         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   27D0 10 11 12 13 14 15    25         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
                             26 
                             15 
