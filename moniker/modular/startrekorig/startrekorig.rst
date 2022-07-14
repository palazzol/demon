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
   0001 C3 59 01      [10]    3         JP      INIT        ; go to initialization code
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
                              9         .include "io.asm" 
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
   000B                      15 SETSCL:
   000B 7A            [ 4]   16         LD      A,D
   000C F6 80         [ 7]   17         OR      0x80
   000E 57            [ 4]   18         LD      D,A
   000F D3 F9         [11]   19         OUT     (CCPORT),A
   0011 CD 68 00      [17]   20         CALL    I2CDELAY
   0014 C9            [10]   21         RET
                             22     
                             23 ; Set the SCL pin low
                             24 ; D is the global coin counter buffer
                             25 ; Destroys A
   0015                      26 CLRSCL:
   0015 7A            [ 4]   27         LD      A,D
   0016 E6 7F         [ 7]   28         AND     0x7F
   0018 57            [ 4]   29         LD      D,A
   0019 D3 F9         [11]   30         OUT     (CCPORT),A
   001B C9            [10]   31         RET
                             32 
                             33 ; Set the DOUT pin low
                             34 ; D is the global coin counter buffer
                             35 ; Destroys A 
   001C                      36 SETSDA:
   001C 7A            [ 4]   37         LD      A,D
   001D E6 BF         [ 7]   38         AND     0xBF
   001F 57            [ 4]   39         LD      D,A
   0020 D3 F9         [11]   40         OUT     (CCPORT),A
   0022 CD 68 00      [17]   41         CALL    I2CDELAY
   0025 C9            [10]   42         RET
                             43 
                             44 ; Set the DOUT pin high
                             45 ; D is the global coin counter buffer
                             46 ; Destroys A  
   0026                      47 CLRSDA:
   0026 7A            [ 4]   48         LD      A,D
   0027 F6 40         [ 7]   49         OR      0x40
   0029 57            [ 4]   50         LD      D,A
   002A D3 F9         [11]   51         OUT     (CCPORT),A
   002C CD 68 00      [17]   52         CALL    I2CDELAY
   002F C9            [10]   53         RET
                             54 
                             55 ; Read the DIN pin 
                             56 ; returns bit in carry flag    
   0030                      57 READSDA:
   0030 DB F8         [11]   58         IN      A,(DSPORT)  ;0x08
   0032 CB 3F         [ 8]   59         SRL     A           ;0x04
   0034 CB 3F         [ 8]   60         SRL     A           ;0x02
   0036 CB 3F         [ 8]   61         SRL     A           ;0x01
   0038 CB 3F         [ 8]   62         SRL     A           ;carry flag
   003A C9            [10]   63         RET
                             10         .include "../z80/loop.asm"
   003B                       1 EVERY:  
                              2 ;       YOUR CODE CAN GO HERE
   003B C9            [10]    3         RET
                             11 
                             12 	; This section must end before the end of the chip
                             13         .bank   second   (base=NMIADD, size=ENDADD-NMIADD)
                             14         .area   second   (ABS, BANK=second)
                             15 
                             16         .include "../z80/nmi.asm"
   0066 ED 45         [14]    1 NMI:    RETN
                             17         .include "../z80/main.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; RAM Variables	
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                     CFF0     5 CMDBUF  .equ    RAMADDR         ; Need only 4 bytes of ram for command buffer
                              6 
                              7 ; Delay for half a bit time
   0068                       8 I2CDELAY:
   0068 C9            [10]    9         RET     ; This is plenty
                             10 
                             11 ; I2C Start Condition
                             12 ; Uses HL
                             13 ; Destroys A
   0069                      14 I2CSTART:
   0069 CD 26 00      [17]   15         CALL    CLRSDA      
   006C CD 15 00      [17]   16         CALL    CLRSCL
   006F C9            [10]   17         RET
                             18 
                             19 ; I2C Stop Condition
                             20 ; Uses HL
                             21 ; Destroys A
   0070                      22 I2CSTOP:
   0070 CD 26 00      [17]   23         CALL    CLRSDA
   0073 CD 0B 00      [17]   24         CALL    SETSCL
   0076 CD 1C 00      [17]   25         CALL    SETSDA
   0079 C9            [10]   26         RET
                             27 
                             28 ; I2C Read Bit routine
                             29 ; Returns bit in carry blag
                             30 ; Destroys A
   007A                      31 I2CRBIT:
   007A CD 1C 00      [17]   32         CALL    SETSDA
   007D CD 0B 00      [17]   33         CALL    SETSCL
   0080 CD 30 00      [17]   34         CALL    READSDA
   0083 F5            [11]   35         PUSH    AF          ; save carry flag
   0084 CD 15 00      [17]   36         CALL    CLRSCL
   0087 F1            [10]   37         POP     AF          ; rv in carry flag
   0088 C9            [10]   38         RET
                             39 
                             40 ; I2C Write Bit routine
                             41 ; Takes carry flag
                             42 ; Destroys A
   0089                      43 I2CWBIT:
   0089 30 05         [12]   44         JR      NC,DOCLR
   008B CD 1C 00      [17]   45         CALL    SETSDA
   008E 18 03         [12]   46         JR      AHEAD
   0090                      47 DOCLR:
   0090 CD 26 00      [17]   48         CALL    CLRSDA
   0093                      49 AHEAD:
   0093 CD 0B 00      [17]   50         CALL    SETSCL
   0096 CD 15 00      [17]   51         CALL    CLRSCL
   0099 C9            [10]   52         RET
                             53 
                             54 ; I2C Write Byte routine
                             55 ; Takes A
                             56 ; Destroys B
                             57 ; Returns carry bit
   009A                      58 I2CWBYTE:
   009A 06 08         [ 7]   59         LD      B,8
   009C                      60 ILOOP:
   009C C5            [11]   61         PUSH    BC          ; save B
   009D CB 07         [ 8]   62         RLC     A    
   009F F5            [11]   63         PUSH    AF          ; save A
   00A0 CD 89 00      [17]   64         CALL    I2CWBIT
   00A3 F1            [10]   65         POP     AF
   00A4 C1            [10]   66         POP     BC
   00A5 10 F5         [13]   67         DJNZ    ILOOP
   00A7 CD 7A 00      [17]   68         CALL    I2CRBIT
   00AA C9            [10]   69         RET
                             70 
                             71 ; I2C Read Byte routine
                             72 ; Destroys BC
                             73 ; Returns A
   00AB                      74 I2CRBYTE:
   00AB 06 08         [ 7]   75         LD      B,8
   00AD 0E 00         [ 7]   76         LD      C,0
   00AF                      77 LOOP3:
   00AF C5            [11]   78         PUSH    BC
   00B0 CD 7A 00      [17]   79         CALL    I2CRBIT     ; get bit in carry flag
   00B3 C1            [10]   80         POP     BC
   00B4 CB 11         [ 8]   81         RL      C           ; rotate carry into bit0 of C register
   00B6 10 F7         [13]   82         DJNZ    LOOP3
   00B8 AF            [ 4]   83         XOR     A           ; clear carry flag              
   00B9 C5            [11]   84         PUSH    BC
   00BA CD 89 00      [17]   85         CALL    I2CWBIT
   00BD C1            [10]   86         POP     BC
   00BE 79            [ 4]   87         LD      A,C
   00BF C9            [10]   88         RET
                             89 ;
                             90 
                             91 ; Read 4-byte I2C Command from device into CMDBUF
                             92 ; Uses HL
                             93 ; Destroys A,BC,HL
   00C0                      94 I2CRREQ:
   00C0 CD 69 00      [17]   95         CALL    I2CSTART
   00C3 3E 11         [ 7]   96         LD      A,I2CRADR
   00C5 CD 9A 00      [17]   97         CALL    I2CWBYTE
   00C8 38 1A         [12]   98         JR      C,SKIP
   00CA CD AB 00      [17]   99         CALL    I2CRBYTE
   00CD DD 77 00      [19]  100         LD      (IX),A
   00D0 CD AB 00      [17]  101         CALL    I2CRBYTE
   00D3 DD 77 01      [19]  102         LD      (IX+1),A  
   00D6 CD AB 00      [17]  103         CALL    I2CRBYTE
   00D9 DD 77 02      [19]  104         LD      (IX+2),A
   00DC CD AB 00      [17]  105         CALL    I2CRBYTE
   00DF DD 77 03      [19]  106         LD      (IX+3),A
   00E2 18 14         [12]  107         JR      ENDI2C
                            108     
   00E4                     109 SKIP:                       ; If no device present, fake an idle response
   00E4 3E 2E         [ 7]  110         LD      A,0x2e  ; '.'
   00E6 DD 77 00      [19]  111         LD      (IX),A
   00E9 18 0D         [12]  112         JR      ENDI2C
                            113 
   00EB                     114 I2CSRESP:
   00EB F5            [11]  115         PUSH    AF
   00EC CD 69 00      [17]  116         CALL    I2CSTART
   00EF 3E 10         [ 7]  117         LD      A,I2CWADR
   00F1 CD 9A 00      [17]  118         CALL    I2CWBYTE
   00F4 F1            [10]  119         POP     AF
   00F5 CD 9A 00      [17]  120         CALL    I2CWBYTE
   00F8                     121 ENDI2C:
   00F8 CD 70 00      [17]  122         CALL    I2CSTOP
   00FB C9            [10]  123         RET
                            124 ;
                            125 
                            126 ; Main Polling loop
                            127 ; Return carry flag if we got a valid command (not idle)
   00FC                     128 POLL:
   00FC CD C0 00      [17]  129         CALL    I2CRREQ
   00FF DD 7E 00      [19]  130         LD      A,(IX)
   0102 FE 52         [ 7]  131         CP      0x52    ; 'R' - Read memory
   0104 28 1B         [12]  132         JR      Z,MREAD
   0106 FE 57         [ 7]  133         CP      0x57    ; 'W' - Write memory
   0108 28 1D         [12]  134         JR      Z,MWRITE
   010A FE 49         [ 7]  135         CP      0x49    ; 'I' - Input from port
   010C 28 2D         [12]  136         JR      Z,PREAD
   010E FE 4F         [ 7]  137         CP      0x4F    ; 'O' - Output from port
   0110 28 30         [12]  138         JR      Z,PWRITE
   0112 FE 43         [ 7]  139         CP      0x43    ; 'C' - Call subroutine
   0114 28 3B         [12]  140         JR      Z,REMCALL
   0116 3F            [ 4]  141         CCF
   0117 C9            [10]  142         RET
   0118                     143 LOADHL:
   0118 DD 7E 01      [19]  144         LD      A,(IX+1)
   011B 67            [ 4]  145         LD      H,A
   011C DD 7E 02      [19]  146         LD      A,(IX+2)
   011F 6F            [ 4]  147         LD      L,A
   0120 C9            [10]  148         RET    
   0121                     149 MREAD:
   0121 CD 32 01      [17]  150         CALL    LOADBC
   0124 0A            [ 7]  151         LD      A,(BC)
   0125 18 25         [12]  152         JR      SRESP
   0127                     153 MWRITE:
   0127 CD 32 01      [17]  154         CALL    LOADBC
   012A DD 7E 03      [19]  155         LD      A,(IX+3)
   012D 02            [ 7]  156         LD      (BC),A
   012E 3E 57         [ 7]  157         LD      A,0x57  ;'W'
   0130 18 1A         [12]  158         JR      SRESP
   0132                     159 LOADBC:
   0132 DD 7E 01      [19]  160         LD      A,(IX+1)
   0135 47            [ 4]  161         LD      B,A
   0136 DD 7E 02      [19]  162         LD      A,(IX+2)
   0139 4F            [ 4]  163         LD      C,A
   013A C9            [10]  164         RET
   013B                     165 PREAD:
   013B CD 32 01      [17]  166         CALL    LOADBC
   013E ED 78         [12]  167         IN      A,(C)
   0140 18 0A         [12]  168         JR      SRESP
   0142                     169 PWRITE:
   0142 CD 32 01      [17]  170         CALL    LOADBC
   0145 DD 7E 03      [19]  171         LD      A,(IX+3)
   0148 ED 79         [12]  172         OUT     (C),A
   014A 3E 4F         [ 7]  173         LD      A,0x4F  ;'O'
   014C                     174 SRESP:
   014C CD EB 00      [17]  175         CALL    I2CSRESP
   014F                     176 RHERE:
   014F 37            [ 4]  177         SCF
   0150 C9            [10]  178         RET
   0151                     179 REMCALL:
   0151 21 00 00      [10]  180         LD      HL,START
   0154 E5            [11]  181         PUSH    HL
   0155 CD 18 01      [17]  182         CALL    LOADHL
   0158 E9            [ 4]  183         JP      (HL)
                            184     
   0159                     185 INIT:
   0159 31 F0 CF      [10]  186         LD      SP,RAMADDR  ; have to set valid SP
   015C DD 21 F0 CF   [14]  187         LD      IX,CMDBUF   ; Easy to index command buffer
                            188         
   0160 CD 04 00      [17]  189         CALL    ONCE
                            190 
                            191 ; Main routine
   0163                     192 MAIN:
   0163 CD 3B 00      [17]  193         CALL    EVERY
   0166 CD FC 00      [17]  194         CALL    POLL
   0169 38 F8         [12]  195         JR      C,MAIN
                            196         
   016B 01 80 01      [10]  197         LD      BC,BIGDEL
   016E                     198 DLOOP:
   016E 0B            [ 6]  199         DEC     BC
   016F 79            [ 4]  200         LD      A,C
   0170 B0            [ 4]  201         OR      B
   0171 20 FB         [12]  202         JR      NZ,DLOOP
   0173 18 EE         [12]  203         JR      MAIN
