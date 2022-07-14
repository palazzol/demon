                              1 
                              2         .include "settings.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; You will need to adjust these variables for different targets
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                              5 ; RAM SETTINGS
                              6 
                     DFF0     7 RAMADDR .equ    0xdff0      ; Start of RAM variables - need only 4 bytes here, but we have 16
                              8                             ; Stack will grow towards 0 from this point
                              9 
                             10 ; ROM SETTINGS - usually the first 2K of memory for z80
                             11 
                     0000    12 STRTADD .equ    0x0000      ; start of chip memory mapping
                     0038    13 IRQ1ADD .equ    0x0038      ; IRQ
                     0066    14 NMIADD  .equ    0x0066      ; location of NMI handler
                     0800    15 ENDADD  .equ    0x0800      ; end of chip memory mapping (+1)
                             16 
                             17 ; TIMER SETTING
                     0180    18 BIGDEL  .equ    0x0180      ;delay factor
                             19 
                             20 ; I2C ADDRESSING
                     0011    21 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    22 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                              3         
                              4         ; This section must end before NMI Handler
                              5         .bank   first   (base=STRTADD, size=NMIADD-STRTADD)
                              6         .area   first   (ABS, BANK=first)
                              7 
                              8         .include "../z80/startup.asm"
                              1 
   0000 F3            [ 4]    2 START:  DI                  ; Disable interrupts - we don't handle them
   0001 C3 9B 01      [10]    3         JP      INIT        ; go to initialization code
                              4 
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 ; This function is called once, and should be used do any game-specific
                              7 ; initialization that is required
                              8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              9 
   0004                      10 ONCE:   
                             11 ;       YOUR CODE CAN GO HERE
   0004 C9            [10]   12         RET
                              9         .include "irq.asm"
                              1 
   0038                       2         .org    IRQ1ADD
                              3 
   0038 F5            [11]    4         PUSH    af
   0039 3E 01         [ 7]    5         ld      a,0x01
   003B 32 01 DF      [13]    6         ld      (0xdf01),A
   003E F1            [10]    7         POP     af
   003F ED 4D         [14]    8         RETI
                              9         
                             10 
                             11 	; This section must end before the end of the chip
                             12         .bank   second   (base=NMIADD, size=ENDADD-NMIADD)
                             13         .area   second   (ABS, BANK=second)
                             14 
                             15         .include "../z80/nmi.asm"
   0066 ED 45         [14]    1 NMI:    RETN
                             16 
                             17         .include "../z80/romio.asm" 
                     0400     1 IOREG    .equ   STRTADD+0x0400
                     0400     2 IOREGR   .equ	STRTADD+0x0400    ;reserved region for IO READ
                     0500     3 IOREGW   .equ	STRTADD+0x0500    ;reserved region for IO WRITE
                              4 
                              5 ; Set the SCL pin high
                              6 ; D is the global coin counter buffer
                              7 ; Destroys A
   0068                       8 SETSCL:
   0068 7A            [ 4]    9         LD      A,D
   0069 F6 01         [ 7]   10         OR      0x01
   006B 57            [ 4]   11         LD      D,A
   006C E5            [11]   12         PUSH    HL
   006D 26 05         [ 7]   13         LD      H,#>IOREGW
   006F 6F            [ 4]   14         LD      L,A
   0070 7E            [ 7]   15         LD      A,(HL)
   0071 E1            [10]   16         POP     HL
   0072 CD AA 00      [17]   17         CALL    I2CDELAY
   0075 C9            [10]   18         RET
                             19     
                             20 ; Set the SCL pin low
                             21 ; D is the global coin counter buffer
                             22 ; Destroys A
   0076                      23 CLRSCL:
   0076 7A            [ 4]   24         LD      A,D
   0077 E6 FE         [ 7]   25         AND     0xFE
   0079 57            [ 4]   26         LD      D,A
   007A E5            [11]   27         PUSH    HL
   007B 26 05         [ 7]   28         LD      H,#>IOREGW
   007D 6F            [ 4]   29         LD      L,A
   007E 7E            [ 7]   30         LD      A,(HL)
   007F E1            [10]   31         POP     HL
   0080 C9            [10]   32         RET
                             33 
                             34 ; Set the DOUT pin low
                             35 ; D is the global coin counter buffer
                             36 ; Destroys A 
   0081                      37 SETSDA:
   0081 7A            [ 4]   38         LD      A,D
   0082 E6 FD         [ 7]   39         AND     0xFD
   0084 57            [ 4]   40         LD      D,A
   0085 E5            [11]   41         PUSH    HL
   0086 26 05         [ 7]   42         LD      H,#>IOREGW
   0088 6F            [ 4]   43         LD      L,A
   0089 7E            [ 7]   44         LD      A,(HL)
   008A E1            [10]   45         POP     HL
   008B CD AA 00      [17]   46         CALL    I2CDELAY
   008E C9            [10]   47         RET
                             48 
                             49 ; Set the DOUT pin high
                             50 ; D is the global coin counter buffer
                             51 ; Destroys A  
   008F                      52 CLRSDA:
   008F 7A            [ 4]   53         LD      A,D
   0090 F6 02         [ 7]   54         OR      0x02
   0092 57            [ 4]   55         LD      D,A
   0093 E5            [11]   56         PUSH    HL
   0094 26 05         [ 7]   57         LD      H,#>IOREGW
   0096 6F            [ 4]   58         LD      L,A
   0097 7E            [ 7]   59         LD      A,(HL)
   0098 E1            [10]   60         POP     HL
   0099 CD AA 00      [17]   61         CALL    I2CDELAY
   009C C9            [10]   62         RET
                             63 
                             64 ; Read the DIN pin 
                             65 ; returns bit in carry flag    
   009D                      66 READSDA:
   009D 7A            [ 4]   67         LD      A,D
   009E E5            [11]   68         PUSH    HL
   009F 26 04         [ 7]   69         LD      H,#>IOREGR
   00A1 6F            [ 4]   70         LD      L,A
   00A2 7E            [ 7]   71         LD      A,(HL)
   00A3 E1            [10]   72         POP     HL
   00A4 CB 3F         [ 8]   73         SRL     A           ;carry flag
   00A6 C9            [10]   74         RET
                             18         .include "loop.asm"
   00A7                       1 EVERY:  
   00A7 DB 10         [11]    2 	IN	A,(0x10)    ; hit watchdog
   00A9 C9            [10]    3         RET
                             19 
                             20         .include "../z80/main.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; RAM Variables	
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                     DFF0     5 CMDBUF  .equ    RAMADDR         ; Need only 4 bytes of ram for command buffer
                              6 
                              7 ; Delay for half a bit time
   00AA                       8 I2CDELAY:
   00AA C9            [10]    9         RET     ; This is plenty
                             10 
                             11 ; I2C Start Condition
                             12 ; Uses HL
                             13 ; Destroys A
   00AB                      14 I2CSTART:
   00AB CD 8F 00      [17]   15         CALL    CLRSDA      
   00AE CD 76 00      [17]   16         CALL    CLRSCL
   00B1 C9            [10]   17         RET
                             18 
                             19 ; I2C Stop Condition
                             20 ; Uses HL
                             21 ; Destroys A
   00B2                      22 I2CSTOP:
   00B2 CD 8F 00      [17]   23         CALL    CLRSDA
   00B5 CD 68 00      [17]   24         CALL    SETSCL
   00B8 CD 81 00      [17]   25         CALL    SETSDA
   00BB C9            [10]   26         RET
                             27 
                             28 ; I2C Read Bit routine
                             29 ; Returns bit in carry blag
                             30 ; Destroys A
   00BC                      31 I2CRBIT:
   00BC CD 81 00      [17]   32         CALL    SETSDA
   00BF CD 68 00      [17]   33         CALL    SETSCL
   00C2 CD 9D 00      [17]   34         CALL    READSDA
   00C5 F5            [11]   35         PUSH    AF          ; save carry flag
   00C6 CD 76 00      [17]   36         CALL    CLRSCL
   00C9 F1            [10]   37         POP     AF          ; rv in carry flag
   00CA C9            [10]   38         RET
                             39 
                             40 ; I2C Write Bit routine
                             41 ; Takes carry flag
                             42 ; Destroys A
   00CB                      43 I2CWBIT:
   00CB 30 05         [12]   44         JR      NC,DOCLR
   00CD CD 81 00      [17]   45         CALL    SETSDA
   00D0 18 03         [12]   46         JR      AHEAD
   00D2                      47 DOCLR:
   00D2 CD 8F 00      [17]   48         CALL    CLRSDA
   00D5                      49 AHEAD:
   00D5 CD 68 00      [17]   50         CALL    SETSCL
   00D8 CD 76 00      [17]   51         CALL    CLRSCL
   00DB C9            [10]   52         RET
                             53 
                             54 ; I2C Write Byte routine
                             55 ; Takes A
                             56 ; Destroys B
                             57 ; Returns carry bit
   00DC                      58 I2CWBYTE:
   00DC 06 08         [ 7]   59         LD      B,8
   00DE                      60 ILOOP:
   00DE C5            [11]   61         PUSH    BC          ; save B
   00DF CB 07         [ 8]   62         RLC     A    
   00E1 F5            [11]   63         PUSH    AF          ; save A
   00E2 CD CB 00      [17]   64         CALL    I2CWBIT
   00E5 F1            [10]   65         POP     AF
   00E6 C1            [10]   66         POP     BC
   00E7 10 F5         [13]   67         DJNZ    ILOOP
   00E9 CD BC 00      [17]   68         CALL    I2CRBIT
   00EC C9            [10]   69         RET
                             70 
                             71 ; I2C Read Byte routine
                             72 ; Destroys BC
                             73 ; Returns A
   00ED                      74 I2CRBYTE:
   00ED 06 08         [ 7]   75         LD      B,8
   00EF 0E 00         [ 7]   76         LD      C,0
   00F1                      77 LOOP3:
   00F1 C5            [11]   78         PUSH    BC
   00F2 CD BC 00      [17]   79         CALL    I2CRBIT     ; get bit in carry flag
   00F5 C1            [10]   80         POP     BC
   00F6 CB 11         [ 8]   81         RL      C           ; rotate carry into bit0 of C register
   00F8 10 F7         [13]   82         DJNZ    LOOP3
   00FA AF            [ 4]   83         XOR     A           ; clear carry flag              
   00FB C5            [11]   84         PUSH    BC
   00FC CD CB 00      [17]   85         CALL    I2CWBIT
   00FF C1            [10]   86         POP     BC
   0100 79            [ 4]   87         LD      A,C
   0101 C9            [10]   88         RET
                             89 ;
                             90 
                             91 ; Read 4-byte I2C Command from device into CMDBUF
                             92 ; Uses HL
                             93 ; Destroys A,BC,HL
   0102                      94 I2CRREQ:
   0102 CD AB 00      [17]   95         CALL    I2CSTART
   0105 3E 11         [ 7]   96         LD      A,I2CRADR
   0107 CD DC 00      [17]   97         CALL    I2CWBYTE
   010A 38 1A         [12]   98         JR      C,SKIP
   010C CD ED 00      [17]   99         CALL    I2CRBYTE
   010F DD 77 00      [19]  100         LD      (IX),A
   0112 CD ED 00      [17]  101         CALL    I2CRBYTE
   0115 DD 77 01      [19]  102         LD      (IX+1),A  
   0118 CD ED 00      [17]  103         CALL    I2CRBYTE
   011B DD 77 02      [19]  104         LD      (IX+2),A
   011E CD ED 00      [17]  105         CALL    I2CRBYTE
   0121 DD 77 03      [19]  106         LD      (IX+3),A
   0124 18 14         [12]  107         JR      ENDI2C
                            108     
   0126                     109 SKIP:                       ; If no device present, fake an idle response
   0126 3E 2E         [ 7]  110         LD      A,0x2e  ; '.'
   0128 DD 77 00      [19]  111         LD      (IX),A
   012B 18 0D         [12]  112         JR      ENDI2C
                            113 
   012D                     114 I2CSRESP:
   012D F5            [11]  115         PUSH    AF
   012E CD AB 00      [17]  116         CALL    I2CSTART
   0131 3E 10         [ 7]  117         LD      A,I2CWADR
   0133 CD DC 00      [17]  118         CALL    I2CWBYTE
   0136 F1            [10]  119         POP     AF
   0137 CD DC 00      [17]  120         CALL    I2CWBYTE
   013A                     121 ENDI2C:
   013A CD B2 00      [17]  122         CALL    I2CSTOP
   013D C9            [10]  123         RET
                            124 ;
                            125 
                            126 ; Main Polling loop
                            127 ; Return carry flag if we got a valid command (not idle)
   013E                     128 POLL:
   013E CD 02 01      [17]  129         CALL    I2CRREQ
   0141 DD 7E 00      [19]  130         LD      A,(IX)
   0144 FE 52         [ 7]  131         CP      0x52    ; 'R' - Read memory
   0146 28 1B         [12]  132         JR      Z,MREAD
   0148 FE 57         [ 7]  133         CP      0x57    ; 'W' - Write memory
   014A 28 1D         [12]  134         JR      Z,MWRITE
   014C FE 49         [ 7]  135         CP      0x49    ; 'I' - Input from port
   014E 28 2D         [12]  136         JR      Z,PREAD
   0150 FE 4F         [ 7]  137         CP      0x4F    ; 'O' - Output from port
   0152 28 30         [12]  138         JR      Z,PWRITE
   0154 FE 43         [ 7]  139         CP      0x43    ; 'C' - Call subroutine
   0156 28 3B         [12]  140         JR      Z,REMCALL
   0158 3F            [ 4]  141         CCF
   0159 C9            [10]  142         RET
   015A                     143 LOADHL:
   015A DD 7E 01      [19]  144         LD      A,(IX+1)
   015D 67            [ 4]  145         LD      H,A
   015E DD 7E 02      [19]  146         LD      A,(IX+2)
   0161 6F            [ 4]  147         LD      L,A
   0162 C9            [10]  148         RET    
   0163                     149 MREAD:
   0163 CD 74 01      [17]  150         CALL    LOADBC
   0166 0A            [ 7]  151         LD      A,(BC)
   0167 18 25         [12]  152         JR      SRESP
   0169                     153 MWRITE:
   0169 CD 74 01      [17]  154         CALL    LOADBC
   016C DD 7E 03      [19]  155         LD      A,(IX+3)
   016F 02            [ 7]  156         LD      (BC),A
   0170 3E 57         [ 7]  157         LD      A,0x57  ;'W'
   0172 18 1A         [12]  158         JR      SRESP
   0174                     159 LOADBC:
   0174 DD 7E 01      [19]  160         LD      A,(IX+1)
   0177 47            [ 4]  161         LD      B,A
   0178 DD 7E 02      [19]  162         LD      A,(IX+2)
   017B 4F            [ 4]  163         LD      C,A
   017C C9            [10]  164         RET
   017D                     165 PREAD:
   017D CD 74 01      [17]  166         CALL    LOADBC
   0180 ED 78         [12]  167         IN      A,(C)
   0182 18 0A         [12]  168         JR      SRESP
   0184                     169 PWRITE:
   0184 CD 74 01      [17]  170         CALL    LOADBC
   0187 DD 7E 03      [19]  171         LD      A,(IX+3)
   018A ED 79         [12]  172         OUT     (C),A
   018C 3E 4F         [ 7]  173         LD      A,0x4F  ;'O'
   018E                     174 SRESP:
   018E CD 2D 01      [17]  175         CALL    I2CSRESP
   0191                     176 RHERE:
   0191 37            [ 4]  177         SCF
   0192 C9            [10]  178         RET
   0193                     179 REMCALL:
   0193 21 00 00      [10]  180         LD      HL,START
   0196 E5            [11]  181         PUSH    HL
   0197 CD 5A 01      [17]  182         CALL    LOADHL
   019A E9            [ 4]  183         JP      (HL)
                            184     
   019B                     185 INIT:
   019B 31 F0 DF      [10]  186         LD      SP,RAMADDR  ; have to set valid SP
   019E DD 21 F0 DF   [14]  187         LD      IX,CMDBUF   ; Easy to index command buffer
                            188         
   01A2 CD 04 00      [17]  189         CALL    ONCE
                            190 
                            191 ; Main routine
   01A5                     192 MAIN:
   01A5 CD A7 00      [17]  193         CALL    EVERY
   01A8 CD 3E 01      [17]  194         CALL    POLL
   01AB 38 F8         [12]  195         JR      C,MAIN
                            196         
   01AD 01 80 01      [10]  197         LD      BC,BIGDEL
   01B0                     198 DLOOP:
   01B0 0B            [ 6]  199         DEC     BC
   01B1 79            [ 4]  200         LD      A,C
   01B2 B0            [ 4]  201         OR      B
   01B3 20 FB         [12]  202         JR      NZ,DLOOP
   01B5 18 EE         [12]  203         JR      MAIN
                             21 
                             22         .bank   third   (base=STRTADD+0x0500, size=0x100)
                             23         .area   third   (ABS, BANK=third)
                             24         
                             25         .include "../z80/romiow.asm"
                              1 
                              2 ; 
                              3 ; In earlier hardware designs, I tried to capture the address bus bits on a 
                              4 ; read cycle, to use to write to the Arduino.  But it turns out it is impossible
                              5 ; to know exactly when to sample these address bits across all platforms, designs, and 
                              6 ; clock speeds
                              7 ;
                              8 ; The solution I came up with was to make sure the data bus contains the same information
                              9 ; as the lower address bus during these read cycles, so that I can sample the data bus just like the 
                             10 ; CPU would.
                             11 ;
                             12 ; This block of memory, starting at 0x0500, is filled with consecutive integers.
                             13 ; When the CPU reads from a location, the data bus matches the lower bits of the address bus.  
                             14 ; And the data bus read by the CPU is also written to the Arduino.
                             15 ; 
                             16 ; Note: Currently, only the bottom two bits are used, but reserving the memory
                             17 ; this way insures that up to 8 bits could be used 
                             18 ; 
   0500 00 01 02 03 04 05    19         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   0510 10 11 12 13 14 15    20         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
   0520 20 21 22 23 24 25    21         .DB     0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f
        26 27 28 29 2A 2B
        2C 2D 2E 2F
   0530 30 31 32 33 34 35    22         .DB     0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,0x3e,0x3f
        36 37 38 39 3A 3B
        3C 3D 3E 3F
   0540 40 41 42 43 44 45    23         .DB     0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f
        46 47 48 49 4A 4B
        4C 4D 4E 4F
   0550 50 51 52 53 54 55    24         .DB     0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0x5b,0x5c,0x5d,0x5e,0x5f
        56 57 58 59 5A 5B
        5C 5D 5E 5F
   0560 60 61 62 63 64 65    25         .DB     0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f
        66 67 68 69 6A 6B
        6C 6D 6E 6F
   0570 70 71 72 73 74 75    26         .DB     0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,0x7b,0x7c,0x7d,0x7e,0x7f
        76 77 78 79 7A 7B
        7C 7D 7E 7F
   0580 80 81 82 83 84 85    27         .DB     0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f
        86 87 88 89 8A 8B
        8C 8D 8E 8F
   0590 90 91 92 93 94 95    28         .DB     0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9a,0x9b,0x9c,0x9d,0x9e,0x9f
        96 97 98 99 9A 9B
        9C 9D 9E 9F
   05A0 A0 A1 A2 A3 A4 A5    29         .DB     0xa0,0xa1,0xa2,0xa3,0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xaa,0xab,0xac,0xad,0xae,0xaf
        A6 A7 A8 A9 AA AB
        AC AD AE AF
   05B0 B0 B1 B2 B3 B4 B5    30         .DB     0xb0,0xb1,0xb2,0xb3,0xb4,0xb5,0xb6,0xb7,0xb8,0xb9,0xba,0xbb,0xbc,0xbd,0xbe,0xbf
        B6 B7 B8 B9 BA BB
        BC BD BE BF
   05C0 C0 C1 C2 C3 C4 C5    31         .DB     0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xc8,0xc9,0xca,0xcb,0xcc,0xcd,0xce,0xcf
        C6 C7 C8 C9 CA CB
        CC CD CE CF
   05D0 D0 D1 D2 D3 D4 D5    32         .DB     0xd0,0xd1,0xd2,0xd3,0xd4,0xd5,0xd6,0xd7,0xd8,0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xdf
        D6 D7 D8 D9 DA DB
        DC DD DE DF
   05E0 E0 E1 E2 E3 E4 E5    33         .DB     0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe6,0xe7,0xe8,0xe9,0xea,0xeb,0xec,0xed,0xee,0xef
        E6 E7 E8 E9 EA EB
        EC ED EE EF
   05F0 F0 F1 F2 F3 F4 F5    34         .DB     0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc,0xfd,0xfe,0xff
        F6 F7 F8 F9 FA FB
        FC FD FE FF
