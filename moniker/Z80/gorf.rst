                              1 ;
                              2 ; Moniker - Z80 Version
                              3 ; by Frank Palazzolo
                              4 ; For Gorf
                              5 ;
                              6 ; SCL  - IN  0x16, bit0 lamp0 (selected by A11,A10,A9, Data is A8)
                              7 ; DOUT - IN  0x16, bit1 lamp1 (selected by A11,A10,A9, Data is A8)
                              8 ; DIN  - IN  0x13, bit0, (0x01) DIP, SW1
                              9 ;
                             10         .area   CODE1   (ABS)   ; ASXXXX directive, absolute addressing
                             11 
                     0013    12 DSPORT  .equ    0x13        ; dip switch 1 port
                     0016    13 CCPORT  .equ    0x16        ; port for lamps
                             14 
                     DFF0    15 CMDBUF  .equ    0xdff0      ; Need only 4 bytes of ram for command buffer
                             16                             ; (We will save 12 more just in case)
                     DFF0    17 SSTACK  .equ    0xdff0      ; Start of stack
                             18 
                     0011    19 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    20 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                             21 
                     0180    22 BIGDEL  .equ    0x0180      ; bigger delay, for now still fairly small
                             23 
   0000                      24         .org    0x0000
                             25     
   0000 F3            [ 4]   26 START:  DI                  ; Disable interrupts - we don't handle them
   0001 C3 28 01      [10]   27         JP      INIT        ; go to initialization code
                             28     
                             29 ; Set the SCL pin high
                             30 ; Destroys A, B and C
   0004                      31 SETSCL:
   0004 06 01         [ 7]   32         LD      B,0x01
   0006 0E 16         [ 7]   33         LD	C,CCPORT
   0008 ED 78         [12]   34         IN      A,(C)
   000A CD 2E 00      [17]   35         CALL    I2CDELAY
   000D C9            [10]   36         RET
                             37     
                             38 ; Set the SCL pin low
                             39 ; Destroys A, B and C
   000E                      40 CLRSCL:
   000E 06 00         [ 7]   41         LD      B,0x00
   0010 0E 16         [ 7]   42         LD	C,CCPORT
   0012 ED 78         [12]   43         IN      A,(C)
   0014 C9            [10]   44         RET
                             45 
                             46 ; Set the DOUT pin low
                             47 ; Destroys A, B and C
   0015                      48 SETSDA:
   0015 06 02         [ 7]   49         LD      B,0x02
   0017 0E 16         [ 7]   50         LD	C,CCPORT
   0019 ED 78         [12]   51         IN      A,(C)
   001B CD 2E 00      [17]   52         CALL    I2CDELAY
   001E C9            [10]   53         RET
                             54 
                             55 ; Set the DOUT pin high
                             56 ; Destroys A, B and C 
   001F                      57 CLRSDA:
   001F 06 03         [ 7]   58         LD      B,0x03
   0021 0E 16         [ 7]   59         LD	C,CCPORT
   0023 ED 78         [12]   60         IN      A,(C)
   0025 CD 2E 00      [17]   61         CALL    I2CDELAY
   0028 C9            [10]   62         RET
                             63 
                             64 ; Read the DIN pin 
                             65 ; returns bit in carry flag    
   0029                      66 READSDA:
   0029 DB 13         [11]   67         IN      A,(DSPORT)  ;0x01
   002B CB 3F         [ 8]   68         SRL     A           ;carry flag
   002D C9            [10]   69         RET
                             70     
                             71 ; Delay for half a bit time
   002E                      72 I2CDELAY:
   002E C9            [10]   73         RET     ; This is plenty
                             74 
                             75 ; I2C Start Condition
                             76 ; Uses HL
                             77 ; Destroys A
   002F                      78 I2CSTART:
   002F CD 1F 00      [17]   79         CALL    CLRSDA      
   0032 CD 0E 00      [17]   80         CALL    CLRSCL
   0035 C9            [10]   81         RET
                             82 
                             83 ; I2C Stop Condition
                             84 ; Uses HL
                             85 ; Destroys A
   0036                      86 I2CSTOP:
   0036 CD 1F 00      [17]   87         CALL    CLRSDA
   0039 CD 04 00      [17]   88         CALL    SETSCL
   003C CD 15 00      [17]   89         CALL    SETSDA
   003F C9            [10]   90         RET
                             91 
                             92 ; I2C Read Bit routine
                             93 ; Returns bit in carry blag
                             94 ; Destroys A
   0040                      95 I2CRBIT:
   0040 CD 15 00      [17]   96         CALL    SETSDA
   0043 CD 04 00      [17]   97         CALL    SETSCL
   0046 CD 29 00      [17]   98         CALL    READSDA
   0049 F5            [11]   99         PUSH    AF          ; save carry flag
   004A CD 0E 00      [17]  100         CALL    CLRSCL
   004D F1            [10]  101         POP     AF          ; rv in carry flag
   004E C9            [10]  102         RET
                            103 
                            104 ; I2C Write Bit routine
                            105 ; Takes carry flag
                            106 ; Destroys A
   004F                     107 I2CWBIT:
   004F 30 05         [12]  108         JR      NC,DOCLR
   0051 CD 15 00      [17]  109         CALL    SETSDA
   0054 18 03         [12]  110         JR      AHEAD
   0056                     111 DOCLR:
   0056 CD 1F 00      [17]  112         CALL    CLRSDA
   0059                     113 AHEAD:
   0059 CD 04 00      [17]  114         CALL    SETSCL
   005C CD 0E 00      [17]  115         CALL    CLRSCL
   005F C9            [10]  116         RET
                            117         
                            118         ; Make sure this code ends before address 0x66 !
                            119         
   0066                     120         .org    0x0066
   0066 C3 00 00      [10]  121 NMI:    JP      START       ; restart on test button press
                            122 
                            123 ; I2C Write Byte routine
                            124 ; Takes A
                            125 ; Destroys B
                            126 ; Returns carry bit
   0069                     127 I2CWBYTE:
   0069 06 08         [ 7]  128         LD      B,8
   006B                     129 ILOOP:
   006B C5            [11]  130         PUSH    BC          ; save B
   006C CB 07         [ 8]  131         RLC     A    
   006E F5            [11]  132         PUSH    AF          ; save A
   006F CD 4F 00      [17]  133         CALL    I2CWBIT
   0072 F1            [10]  134         POP     AF
   0073 C1            [10]  135         POP     BC
   0074 10 F5         [13]  136         DJNZ    ILOOP
   0076 CD 40 00      [17]  137         CALL    I2CRBIT
   0079 C9            [10]  138         RET
                            139 
                            140 ; I2C Read Byte routine
                            141 ; Destroys BC
                            142 ; Returns A
   007A                     143 I2CRBYTE:
   007A 06 08         [ 7]  144         LD      B,8
   007C 0E 00         [ 7]  145         LD      C,0
   007E                     146 LOOP3:
   007E C5            [11]  147         PUSH    BC
   007F CD 40 00      [17]  148         CALL    I2CRBIT     ; get bit in carry flag
   0082 C1            [10]  149         POP     BC
   0083 CB 11         [ 8]  150         RL      C           ; rotate carry into bit0 of C register
   0085 10 F7         [13]  151         DJNZ    LOOP3
   0087 AF            [ 4]  152         XOR     A           ; clear carry flag              
   0088 C5            [11]  153         PUSH    BC
   0089 CD 4F 00      [17]  154         CALL    I2CWBIT
   008C C1            [10]  155         POP     BC
   008D 79            [ 4]  156         LD      A,C
   008E C9            [10]  157         RET
                            158 ;
                            159 
                            160 ; Read 4-byte I2C Command from device into CMDBUF
                            161 ; Uses HL
                            162 ; Destroys A,BC,HL
   008F                     163 I2CRREQ:
   008F CD 2F 00      [17]  164         CALL    I2CSTART
   0092 3E 11         [ 7]  165         LD      A,I2CRADR
   0094 CD 69 00      [17]  166         CALL    I2CWBYTE
   0097 38 1A         [12]  167         JR      C,SKIP
   0099 CD 7A 00      [17]  168         CALL    I2CRBYTE
   009C DD 77 00      [19]  169         LD      (IX),A
   009F CD 7A 00      [17]  170         CALL    I2CRBYTE
   00A2 DD 77 01      [19]  171         LD      (IX+1),A  
   00A5 CD 7A 00      [17]  172         CALL    I2CRBYTE
   00A8 DD 77 02      [19]  173         LD      (IX+2),A
   00AB CD 7A 00      [17]  174         CALL    I2CRBYTE
   00AE DD 77 03      [19]  175         LD      (IX+3),A
   00B1 18 14         [12]  176         JR      ENDI2C
                            177     
   00B3                     178 SKIP:                       ; If no device present, fake an idle response
   00B3 3E 2E         [ 7]  179         LD      A,0x2e  ; '.'
   00B5 DD 77 00      [19]  180         LD      (IX),A
   00B8 18 0D         [12]  181         JR      ENDI2C
                            182 
   00BA                     183 I2CSRESP:
   00BA F5            [11]  184         PUSH    AF
   00BB CD 2F 00      [17]  185         CALL    I2CSTART
   00BE 3E 10         [ 7]  186         LD      A,I2CWADR
   00C0 CD 69 00      [17]  187         CALL    I2CWBYTE
   00C3 F1            [10]  188         POP     AF
   00C4 CD 69 00      [17]  189         CALL    I2CWBYTE
   00C7                     190 ENDI2C:
   00C7 CD 36 00      [17]  191         CALL    I2CSTOP
   00CA C9            [10]  192         RET
                            193 ;
                            194 
                            195 ; Main Polling loop
                            196 ; Return carry flag if we got a valid command (not idle)
   00CB                     197 POLL:
   00CB CD 8F 00      [17]  198         CALL    I2CRREQ
   00CE DD 7E 00      [19]  199         LD      A,(IX)
   00D1 FE 52         [ 7]  200         CP      0x52    ; 'R' - Read memory
   00D3 28 1B         [12]  201         JR      Z,MREAD
   00D5 FE 57         [ 7]  202         CP      0x57    ; 'W' - Write memory
   00D7 28 1D         [12]  203         JR      Z,MWRITE
   00D9 FE 49         [ 7]  204         CP      0x49    ; 'I' - Input from port
   00DB 28 2D         [12]  205         JR      Z,PREAD
   00DD FE 4F         [ 7]  206         CP      0x4F    ; 'O' - Output from port
   00DF 28 30         [12]  207         JR      Z,PWRITE
   00E1 FE 43         [ 7]  208         CP      0x43    ; 'C' - Call subroutine
   00E3 28 3B         [12]  209         JR      Z,REMCALL
   00E5 3F            [ 4]  210         CCF
   00E6 C9            [10]  211         RET
   00E7                     212 LOADHL:
   00E7 DD 7E 01      [19]  213         LD      A,(IX+1)
   00EA 67            [ 4]  214         LD      H,A
   00EB DD 7E 02      [19]  215         LD      A,(IX+2)
   00EE 6F            [ 4]  216         LD      L,A
   00EF C9            [10]  217         RET    
   00F0                     218 MREAD:
   00F0 CD 01 01      [17]  219         CALL    LOADBC
   00F3 0A            [ 7]  220         LD      A,(BC)
   00F4 18 25         [12]  221         JR      SRESP
   00F6                     222 MWRITE:
   00F6 CD 01 01      [17]  223         CALL    LOADBC
   00F9 DD 7E 03      [19]  224         LD      A,(IX+3)
   00FC 02            [ 7]  225         LD      (BC),A
   00FD 3E 57         [ 7]  226         LD      A,0x57  ;'W'
   00FF 18 1A         [12]  227         JR      SRESP
   0101                     228 LOADBC:
   0101 DD 7E 01      [19]  229         LD      A,(IX+1)
   0104 47            [ 4]  230         LD      B,A
   0105 DD 7E 02      [19]  231         LD      A,(IX+2)
   0108 4F            [ 4]  232         LD      C,A
   0109 C9            [10]  233         RET
   010A                     234 PREAD:
   010A CD 01 01      [17]  235         CALL    LOADBC
   010D ED 78         [12]  236         IN      A,(C)
   010F 18 0A         [12]  237         JR      SRESP
   0111                     238 PWRITE:
   0111 CD 01 01      [17]  239         CALL    LOADBC
   0114 DD 7E 03      [19]  240         LD      A,(IX+3)
   0117 ED 79         [12]  241         OUT     (C),A
   0119 3E 4F         [ 7]  242         LD      A,0x4F  ;'O'
   011B                     243 SRESP:
   011B CD BA 00      [17]  244         CALL    I2CSRESP
   011E                     245 RHERE:
   011E 37            [ 4]  246         SCF
   011F C9            [10]  247         RET
   0120                     248 REMCALL:
   0120 21 00 00      [10]  249         LD      HL,START
   0123 E5            [11]  250         PUSH    HL
   0124 CD E7 00      [17]  251         CALL    LOADHL
   0127 E9            [ 4]  252         JP      (HL)
                            253     
   0128                     254 INIT:
   0128 31 F0 DF      [10]  255         LD      SP,SSTACK   ; have to set valid SP
   012B DD 21 F0 DF   [14]  256         LD      IX,CMDBUF   ; Easy to index command buffer
                            257         
                            258 ; Main routine
   012F                     259 MAIN:
   012F DB 10         [11]  260 	IN	A,(0x10)    ; hit watchdog
   0131 CD CB 00      [17]  261         CALL    POLL
   0134 38 F9         [12]  262         JR      C,MAIN
                            263         
   0136 01 80 01      [10]  264         LD      BC,BIGDEL
   0139                     265 MLOOP:
   0139 0B            [ 6]  266         DEC     BC
   013A 79            [ 4]  267         LD      A,C
   013B B0            [ 4]  268         OR      B
   013C 20 FB         [12]  269         JR      NZ,MLOOP
   013E 18 EF         [12]  270         JR      MAIN
                            271 
                            272 
                            273     
                            274 
