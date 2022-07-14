                              1 
                              2         .include "settings.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; You will need to adjust these variables for different targets
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                              5 ; RAM SETTINGS
                              6 
                     CFF0     7 RAMADDR .equ    0xcff0      ; Start of RAM variables - need only 4 bytes here, but we have 16
                              8                             ; Stack will grow towards 0 from this point
                              9 
                             10 ; ROM SETTINGS - usually the first 2K of memory for z80
                             11 
                     0000    12 STRTADD .equ    0x0000      ; start of chip memory mapping
                     0066    13 NMIADD  .equ    0x0066      ; location of NMI handler
                     0800    14 ENDADD  .equ    0x0800      ; end of chip memory mapping (+1)
                             15 
                             16 ; TIMER SETTING
                     0180    17 BIGDEL  .equ    0x0180      ;delay factor
                             18 
                             19 ; I2C ADDRESSING
                     0011    20 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    21 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                              3 
                              4         ; This section must end before NMI Handler
                              5         .bank   first   (base=STRTADD, size=NMIADD-STRTADD)
                              6         .area   first   (ABS, BANK=first)
                              7 
                              8         .include "startup.asm" 
                              1 
   0000 F3            [ 4]    2 START:  DI                  ; Disable interrupts - we don't handle them
   0001 C3 8A 01      [10]    3         JP      INIT        ; go to initialization code
                              4 
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 ; This function is called once, and should be used do any game-specific
                              7 ; initialization that is required
                              8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              9 
   0004                      10 ONCE:   
   0004 3E 81         [ 7]   11         LD      A,0x81
   0006 21 00 E0      [10]   12         LD      HL,0xE000
   0009 77            [ 7]   13         LD      (HL),A      ; blank the screen
   000A C9            [10]   14         RET
                              9 
                             10 	; This section must end before the end of the chip
                             11         .bank   second   (base=NMIADD, size=ENDADD-NMIADD)
                             12         .area   second   (ABS, BANK=second)
                             13 
                             14         .include "../z80/nmi.asm"
   0066 ED 45         [14]    1 NMI:    RETN
                             15         .include "io.asm" 
                              1 ; SCL  - OUT F9, bit7, (0x80) coin counter 1, pin 5, U11 - R1
                              2 ; DOUT - OUT F9, bit6, (0x40) coin counter 2, pin 9, U11 - R3
                              3 ; DIN  - IN  F8, bit3, (0x08) DIP, SW1, pin9, U2-pin 6
                              4 ;
                              5 ; Note: We cannot use opcode 0x32 on this platform, or it will trigger
                              6 ;       the security chip
                              7 ;
                              8 
                     00F8     9 DSPORT  .equ    0xf8        ; dip switch 1 port
                     00F9    10 CCPORT  .equ    0xf9        ; port for count counters
                             11 
                             12 ; Set the SCL pin high
                             13 ; D is the global coin counter buffer
                             14 ; Destroys A
   0068                      15 SETSCL:
   0068 7A            [ 4]   16         LD      A,D
   0069 F6 80         [ 7]   17         OR      0x80
   006B 57            [ 4]   18         LD      D,A
   006C D3 F9         [11]   19         OUT     (CCPORT),A
   006E CD 99 00      [17]   20         CALL    I2CDELAY
   0071 C9            [10]   21         RET
                             22     
                             23 ; Set the SCL pin low
                             24 ; D is the global coin counter buffer
                             25 ; Destroys A
   0072                      26 CLRSCL:
   0072 7A            [ 4]   27         LD      A,D
   0073 E6 7F         [ 7]   28         AND     0x7F
   0075 57            [ 4]   29         LD      D,A
   0076 D3 F9         [11]   30         OUT     (CCPORT),A
   0078 C9            [10]   31         RET
                             32 
                             33 ; Set the DOUT pin low
                             34 ; D is the global coin counter buffer
                             35 ; Destroys A 
   0079                      36 SETSDA:
   0079 7A            [ 4]   37         LD      A,D
   007A E6 BF         [ 7]   38         AND     0xBF
   007C 57            [ 4]   39         LD      D,A
   007D D3 F9         [11]   40         OUT     (CCPORT),A
   007F CD 99 00      [17]   41         CALL    I2CDELAY
   0082 C9            [10]   42         RET
                             43 
                             44 ; Set the DOUT pin high
                             45 ; D is the global coin counter buffer
                             46 ; Destroys A  
   0083                      47 CLRSDA:
   0083 7A            [ 4]   48         LD      A,D
   0084 F6 40         [ 7]   49         OR      0x40
   0086 57            [ 4]   50         LD      D,A
   0087 D3 F9         [11]   51         OUT     (CCPORT),A
   0089 CD 99 00      [17]   52         CALL    I2CDELAY
   008C C9            [10]   53         RET
                             54 
                             55 ; Read the DIN pin 
                             56 ; returns bit in carry flag    
   008D                      57 READSDA:
   008D DB F8         [11]   58         IN      A,(DSPORT)  ;0x08
   008F CB 3F         [ 8]   59         SRL     A           ;0x04
   0091 CB 3F         [ 8]   60         SRL     A           ;0x02
   0093 CB 3F         [ 8]   61         SRL     A           ;0x01
   0095 CB 3F         [ 8]   62         SRL     A           ;carry flag
   0097 C9            [10]   63         RET
                             16         .include "../z80/loop.asm"
   0098                       1 EVERY:  
                              2 ;       YOUR CODE CAN GO HERE
   0098 C9            [10]    3         RET
                             17         .include "../z80/main.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; RAM Variables	
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                     CFF0     5 CMDBUF  .equ    RAMADDR         ; Need only 4 bytes of ram for command buffer
                              6 
                              7 ; Delay for half a bit time
   0099                       8 I2CDELAY:
   0099 C9            [10]    9         RET     ; This is plenty
                             10 
                             11 ; I2C Start Condition
                             12 ; Uses HL
                             13 ; Destroys A
   009A                      14 I2CSTART:
   009A CD 83 00      [17]   15         CALL    CLRSDA      
   009D CD 72 00      [17]   16         CALL    CLRSCL
   00A0 C9            [10]   17         RET
                             18 
                             19 ; I2C Stop Condition
                             20 ; Uses HL
                             21 ; Destroys A
   00A1                      22 I2CSTOP:
   00A1 CD 83 00      [17]   23         CALL    CLRSDA
   00A4 CD 68 00      [17]   24         CALL    SETSCL
   00A7 CD 79 00      [17]   25         CALL    SETSDA
   00AA C9            [10]   26         RET
                             27 
                             28 ; I2C Read Bit routine
                             29 ; Returns bit in carry blag
                             30 ; Destroys A
   00AB                      31 I2CRBIT:
   00AB CD 79 00      [17]   32         CALL    SETSDA
   00AE CD 68 00      [17]   33         CALL    SETSCL
   00B1 CD 8D 00      [17]   34         CALL    READSDA
   00B4 F5            [11]   35         PUSH    AF          ; save carry flag
   00B5 CD 72 00      [17]   36         CALL    CLRSCL
   00B8 F1            [10]   37         POP     AF          ; rv in carry flag
   00B9 C9            [10]   38         RET
                             39 
                             40 ; I2C Write Bit routine
                             41 ; Takes carry flag
                             42 ; Destroys A
   00BA                      43 I2CWBIT:
   00BA 30 05         [12]   44         JR      NC,DOCLR
   00BC CD 79 00      [17]   45         CALL    SETSDA
   00BF 18 03         [12]   46         JR      AHEAD
   00C1                      47 DOCLR:
   00C1 CD 83 00      [17]   48         CALL    CLRSDA
   00C4                      49 AHEAD:
   00C4 CD 68 00      [17]   50         CALL    SETSCL
   00C7 CD 72 00      [17]   51         CALL    CLRSCL
   00CA C9            [10]   52         RET
                             53 
                             54 ; I2C Write Byte routine
                             55 ; Takes A
                             56 ; Destroys B
                             57 ; Returns carry bit
   00CB                      58 I2CWBYTE:
   00CB 06 08         [ 7]   59         LD      B,8
   00CD                      60 ILOOP:
   00CD C5            [11]   61         PUSH    BC          ; save B
   00CE CB 07         [ 8]   62         RLC     A    
   00D0 F5            [11]   63         PUSH    AF          ; save A
   00D1 CD BA 00      [17]   64         CALL    I2CWBIT
   00D4 F1            [10]   65         POP     AF
   00D5 C1            [10]   66         POP     BC
   00D6 10 F5         [13]   67         DJNZ    ILOOP
   00D8 CD AB 00      [17]   68         CALL    I2CRBIT
   00DB C9            [10]   69         RET
                             70 
                             71 ; I2C Read Byte routine
                             72 ; Destroys BC
                             73 ; Returns A
   00DC                      74 I2CRBYTE:
   00DC 06 08         [ 7]   75         LD      B,8
   00DE 0E 00         [ 7]   76         LD      C,0
   00E0                      77 LOOP3:
   00E0 C5            [11]   78         PUSH    BC
   00E1 CD AB 00      [17]   79         CALL    I2CRBIT     ; get bit in carry flag
   00E4 C1            [10]   80         POP     BC
   00E5 CB 11         [ 8]   81         RL      C           ; rotate carry into bit0 of C register
   00E7 10 F7         [13]   82         DJNZ    LOOP3
   00E9 AF            [ 4]   83         XOR     A           ; clear carry flag              
   00EA C5            [11]   84         PUSH    BC
   00EB CD BA 00      [17]   85         CALL    I2CWBIT
   00EE C1            [10]   86         POP     BC
   00EF 79            [ 4]   87         LD      A,C
   00F0 C9            [10]   88         RET
                             89 ;
                             90 
                             91 ; Read 4-byte I2C Command from device into CMDBUF
                             92 ; Uses HL
                             93 ; Destroys A,BC,HL
   00F1                      94 I2CRREQ:
   00F1 CD 9A 00      [17]   95         CALL    I2CSTART
   00F4 3E 11         [ 7]   96         LD      A,I2CRADR
   00F6 CD CB 00      [17]   97         CALL    I2CWBYTE
   00F9 38 1A         [12]   98         JR      C,SKIP
   00FB CD DC 00      [17]   99         CALL    I2CRBYTE
   00FE DD 77 00      [19]  100         LD      (IX),A
   0101 CD DC 00      [17]  101         CALL    I2CRBYTE
   0104 DD 77 01      [19]  102         LD      (IX+1),A  
   0107 CD DC 00      [17]  103         CALL    I2CRBYTE
   010A DD 77 02      [19]  104         LD      (IX+2),A
   010D CD DC 00      [17]  105         CALL    I2CRBYTE
   0110 DD 77 03      [19]  106         LD      (IX+3),A
   0113 18 14         [12]  107         JR      ENDI2C
                            108     
   0115                     109 SKIP:                       ; If no device present, fake an idle response
   0115 3E 2E         [ 7]  110         LD      A,0x2e  ; '.'
   0117 DD 77 00      [19]  111         LD      (IX),A
   011A 18 0D         [12]  112         JR      ENDI2C
                            113 
   011C                     114 I2CSRESP:
   011C F5            [11]  115         PUSH    AF
   011D CD 9A 00      [17]  116         CALL    I2CSTART
   0120 3E 10         [ 7]  117         LD      A,I2CWADR
   0122 CD CB 00      [17]  118         CALL    I2CWBYTE
   0125 F1            [10]  119         POP     AF
   0126 CD CB 00      [17]  120         CALL    I2CWBYTE
   0129                     121 ENDI2C:
   0129 CD A1 00      [17]  122         CALL    I2CSTOP
   012C C9            [10]  123         RET
                            124 ;
                            125 
                            126 ; Main Polling loop
                            127 ; Return carry flag if we got a valid command (not idle)
   012D                     128 POLL:
   012D CD F1 00      [17]  129         CALL    I2CRREQ
   0130 DD 7E 00      [19]  130         LD      A,(IX)
   0133 FE 52         [ 7]  131         CP      0x52    ; 'R' - Read memory
   0135 28 1B         [12]  132         JR      Z,MREAD
   0137 FE 57         [ 7]  133         CP      0x57    ; 'W' - Write memory
   0139 28 1D         [12]  134         JR      Z,MWRITE
   013B FE 49         [ 7]  135         CP      0x49    ; 'I' - Input from port
   013D 28 2D         [12]  136         JR      Z,PREAD
   013F FE 4F         [ 7]  137         CP      0x4F    ; 'O' - Output from port
   0141 28 30         [12]  138         JR      Z,PWRITE
   0143 FE 43         [ 7]  139         CP      0x43    ; 'C' - Call subroutine
   0145 28 3B         [12]  140         JR      Z,REMCALL
   0147 3F            [ 4]  141         CCF
   0148 C9            [10]  142         RET
   0149                     143 LOADHL:
   0149 DD 7E 01      [19]  144         LD      A,(IX+1)
   014C 67            [ 4]  145         LD      H,A
   014D DD 7E 02      [19]  146         LD      A,(IX+2)
   0150 6F            [ 4]  147         LD      L,A
   0151 C9            [10]  148         RET    
   0152                     149 MREAD:
   0152 CD 63 01      [17]  150         CALL    LOADBC
   0155 0A            [ 7]  151         LD      A,(BC)
   0156 18 25         [12]  152         JR      SRESP
   0158                     153 MWRITE:
   0158 CD 63 01      [17]  154         CALL    LOADBC
   015B DD 7E 03      [19]  155         LD      A,(IX+3)
   015E 02            [ 7]  156         LD      (BC),A
   015F 3E 57         [ 7]  157         LD      A,0x57  ;'W'
   0161 18 1A         [12]  158         JR      SRESP
   0163                     159 LOADBC:
   0163 DD 7E 01      [19]  160         LD      A,(IX+1)
   0166 47            [ 4]  161         LD      B,A
   0167 DD 7E 02      [19]  162         LD      A,(IX+2)
   016A 4F            [ 4]  163         LD      C,A
   016B C9            [10]  164         RET
   016C                     165 PREAD:
   016C CD 63 01      [17]  166         CALL    LOADBC
   016F ED 78         [12]  167         IN      A,(C)
   0171 18 0A         [12]  168         JR      SRESP
   0173                     169 PWRITE:
   0173 CD 63 01      [17]  170         CALL    LOADBC
   0176 DD 7E 03      [19]  171         LD      A,(IX+3)
   0179 ED 79         [12]  172         OUT     (C),A
   017B 3E 4F         [ 7]  173         LD      A,0x4F  ;'O'
   017D                     174 SRESP:
   017D CD 1C 01      [17]  175         CALL    I2CSRESP
   0180                     176 RHERE:
   0180 37            [ 4]  177         SCF
   0181 C9            [10]  178         RET
   0182                     179 REMCALL:
   0182 21 00 00      [10]  180         LD      HL,START
   0185 E5            [11]  181         PUSH    HL
   0186 CD 49 01      [17]  182         CALL    LOADHL
   0189 E9            [ 4]  183         JP      (HL)
                            184     
   018A                     185 INIT:
   018A 31 F0 CF      [10]  186         LD      SP,RAMADDR  ; have to set valid SP
   018D DD 21 F0 CF   [14]  187         LD      IX,CMDBUF   ; Easy to index command buffer
   0191 16 00         [ 7]  188         LD      D,#0x00     ; initialize D to prevent index overflow
                            189         
   0193 CD 04 00      [17]  190         CALL    ONCE
                            191 
                            192 ; Main routine
   0196                     193 MAIN:
   0196 CD 98 00      [17]  194         CALL    EVERY
   0199 CD 2D 01      [17]  195         CALL    POLL
   019C 38 F8         [12]  196         JR      C,MAIN
                            197         
   019E 01 80 01      [10]  198         LD      BC,BIGDEL
   01A1                     199 DLOOP:
   01A1 0B            [ 6]  200         DEC     BC
   01A2 79            [ 4]  201         LD      A,C
   01A3 B0            [ 4]  202         OR      B
   01A4 20 FB         [12]  203         JR      NZ,DLOOP
   01A6 18 EE         [12]  204         JR      MAIN
