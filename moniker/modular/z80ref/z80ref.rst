                              1 
                              2         .include "../z80/settings.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; You will need to adjust these variables for different targets
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                              5 ; RAM SETTINGS
                              6 
                     FFF0     7 RAMADDR .equ    0xfff0      ; Start of RAM variables - need only 4 bytes here, but we have 16
                              8                             ; Stack will grow towards 0 from this point
                              9 
                             10 ; ROM SETTINGS - usually the first 2K of memory for z80
                             11 
                     0000    12 STRTADD .equ    0x0000      ; start of chip memory mapping
                     0066    13 NMIADD  .equ    0x0066      ; location of NMI handler
                             14 
                             15 ; TIMER SETTING
                     0180    16 BIGDEL  .equ    0x0180      ; delay factor
                             17 
                             18 ; I2C ADDRESSING
                     0011    19 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    20 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                              3         .include "../z80/romio_defs.asm"
                              1 ; For Demon Debugger Hardware - Rev D 
                              2 
                     07A0     3 IOREGR   .equ   STRTADD+0x07a0    ;reserved region for IO READ
                     07C0     4 IOREGW   .equ   STRTADD+0x07c0    ;reserved region for IO WRITE
                              5 
                     07A0     6 IOADD    .equ   IOREGR            ;start of region
                              4 
                              5         ; This section must end before NMI Handler
                              6         .bank   first   (base=STRTADD, size=NMIADD-STRTADD)
                              7         .area   first   (ABS, BANK=first)
                              8 
                              9         .include "../z80/startup.asm" 
                              1 
   0000 F3            [ 4]    2 START:  DI                  ; Disable interrupts - we don't handle them
   0001 C3 A3 01      [10]    3         JP      INIT        ; go to initialization code
                              4 
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 ; This function is called once, and should be used do any game-specific
                              7 ; initialization that is required
                              8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              9 
   0004                      10 ONCE:   
                             11 ;       YOUR CODE CAN GO HERE
   0004 C9            [10]   12         RET
                             10 
                             11 	; This section must end before the IO Region
                             12         .bank   second   (base=NMIADD, size=IOADD-NMIADD)
                             13         .area   second   (ABS, BANK=second)
                             14 
                             15         .include "../z80/nmi.asm"
   0066 ED 45         [14]    1 NMI:    RETN
                             16         .include "../z80/romio.asm" 
                              1 
                              2 ; For Demon Debugger Hardware - Rev D 
                              3 
                              4 ; Set the SCL pin high
                              5 ; D is the global output buffer
                              6 ; Destroys A
   0068                       7 SETSCL:
   0068 7A            [ 4]    8         LD      A,D
   0069 F6 01         [ 7]    9         OR      0x01
   006B 57            [ 4]   10         LD      D,A
   006C E5            [11]   11         PUSH    HL
   006D 26 07         [ 7]   12         LD      H,#>IOREGW
   006F C6 C0         [ 7]   13         ADD     A,#<IOREGW 
   0071 6F            [ 4]   14         LD      L,A
   0072 7E            [ 7]   15         LD      A,(HL)
   0073 E1            [10]   16         POP     HL
   0074 CD B2 00      [17]   17         CALL    I2CDELAY
   0077 C9            [10]   18         RET
                             19     
                             20 ; Set the SCL pin low
                             21 ; D is the global output buffer
                             22 ; Destroys A
   0078                      23 CLRSCL:
   0078 7A            [ 4]   24         LD      A,D
   0079 E6 1E         [ 7]   25         AND     0x1E
   007B 57            [ 4]   26         LD      D,A
   007C E5            [11]   27         PUSH    HL
   007D 26 07         [ 7]   28         LD      H,#>IOREGW
   007F C6 C0         [ 7]   29         ADD     A,#<IOREGW 
   0081 6F            [ 4]   30         LD      L,A
   0082 7E            [ 7]   31         LD      A,(HL)
   0083 E1            [10]   32         POP     HL
   0084 C9            [10]   33         RET
                             34 
                             35 ; Set the DOUT pin low
                             36 ; D is the global output buffer
                             37 ; Destroys A 
   0085                      38 SETSDA:
   0085 7A            [ 4]   39         LD      A,D
   0086 E6 1D         [ 7]   40         AND     0x1D
   0088 57            [ 4]   41         LD      D,A
   0089 E5            [11]   42         PUSH    HL
   008A 26 07         [ 7]   43         LD      H,#>IOREGW
   008C C6 C0         [ 7]   44         ADD     A,#<IOREGW 
   008E 6F            [ 4]   45         LD      L,A
   008F 7E            [ 7]   46         LD      A,(HL)
   0090 E1            [10]   47         POP     HL
   0091 CD B2 00      [17]   48         CALL    I2CDELAY
   0094 C9            [10]   49         RET
                             50 
                             51 ; Set the DOUT pin high
                             52 ; D is the global output buffer
                             53 ; Destroys A  
   0095                      54 CLRSDA:
   0095 7A            [ 4]   55         LD      A,D
   0096 F6 02         [ 7]   56         OR      0x02
   0098 57            [ 4]   57         LD      D,A
   0099 E5            [11]   58         PUSH    HL
   009A 26 07         [ 7]   59         LD      H,#>IOREGW
   009C C6 C0         [ 7]   60         ADD     A,#<IOREGW 
   009E 6F            [ 4]   61         LD      L,A
   009F 7E            [ 7]   62         LD      A,(HL)
   00A0 E1            [10]   63         POP     HL
   00A1 CD B2 00      [17]   64         CALL    I2CDELAY
   00A4 C9            [10]   65         RET
                             66 
                             67 ; Read the DIN pin 
                             68 ; returns bit in carry flag    
   00A5                      69 READSDA:
   00A5 7A            [ 4]   70         LD      A,D
   00A6 E5            [11]   71         PUSH    HL
   00A7 26 07         [ 7]   72         LD      H,#>IOREGR
   00A9 C6 A0         [ 7]   73         ADD     A,#<IOREGR
   00AB 6F            [ 4]   74         LD      L,A
   00AC 7E            [ 7]   75         LD      A,(HL)
   00AD E1            [10]   76         POP     HL
   00AE CB 3F         [ 8]   77         SRL     A           ;carry flag
   00B0 C9            [10]   78         RET
                             17         .include "../z80/loop.asm"
   00B1                       1 EVERY:  
                              2 ;       YOUR CODE CAN GO HERE
   00B1 C9            [10]    3         RET
                             18         .include "../z80/main.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; RAM Variables	
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                     FFF0     5 CMDBUF  .equ    RAMADDR         ; Need only 4 bytes of ram for command buffer
                              6 
                              7 ; Delay for half a bit time
   00B2                       8 I2CDELAY:
   00B2 C9            [10]    9         RET     ; This is plenty
                             10 
                             11 ; I2C Start Condition
                             12 ; Uses HL
                             13 ; Destroys A
   00B3                      14 I2CSTART:
   00B3 CD 95 00      [17]   15         CALL    CLRSDA      
   00B6 CD 78 00      [17]   16         CALL    CLRSCL
   00B9 C9            [10]   17         RET
                             18 
                             19 ; I2C Stop Condition
                             20 ; Uses HL
                             21 ; Destroys A
   00BA                      22 I2CSTOP:
   00BA CD 95 00      [17]   23         CALL    CLRSDA
   00BD CD 68 00      [17]   24         CALL    SETSCL
   00C0 CD 85 00      [17]   25         CALL    SETSDA
   00C3 C9            [10]   26         RET
                             27 
                             28 ; I2C Read Bit routine
                             29 ; Returns bit in carry blag
                             30 ; Destroys A
   00C4                      31 I2CRBIT:
   00C4 CD 85 00      [17]   32         CALL    SETSDA
   00C7 CD 68 00      [17]   33         CALL    SETSCL
   00CA CD A5 00      [17]   34         CALL    READSDA
   00CD F5            [11]   35         PUSH    AF          ; save carry flag
   00CE CD 78 00      [17]   36         CALL    CLRSCL
   00D1 F1            [10]   37         POP     AF          ; rv in carry flag
   00D2 C9            [10]   38         RET
                             39 
                             40 ; I2C Write Bit routine
                             41 ; Takes carry flag
                             42 ; Destroys A
   00D3                      43 I2CWBIT:
   00D3 30 05         [12]   44         JR      NC,DOCLR
   00D5 CD 85 00      [17]   45         CALL    SETSDA
   00D8 18 03         [12]   46         JR      AHEAD
   00DA                      47 DOCLR:
   00DA CD 95 00      [17]   48         CALL    CLRSDA
   00DD                      49 AHEAD:
   00DD CD 68 00      [17]   50         CALL    SETSCL
   00E0 CD 78 00      [17]   51         CALL    CLRSCL
   00E3 C9            [10]   52         RET
                             53 
                             54 ; I2C Write Byte routine
                             55 ; Takes A
                             56 ; Destroys B
                             57 ; Returns carry bit
   00E4                      58 I2CWBYTE:
   00E4 06 08         [ 7]   59         LD      B,8
   00E6                      60 ILOOP:
   00E6 C5            [11]   61         PUSH    BC          ; save B
   00E7 CB 07         [ 8]   62         RLC     A    
   00E9 F5            [11]   63         PUSH    AF          ; save A
   00EA CD D3 00      [17]   64         CALL    I2CWBIT
   00ED F1            [10]   65         POP     AF
   00EE C1            [10]   66         POP     BC
   00EF 10 F5         [13]   67         DJNZ    ILOOP
   00F1 CD C4 00      [17]   68         CALL    I2CRBIT
   00F4 C9            [10]   69         RET
                             70 
                             71 ; I2C Read Byte routine
                             72 ; Destroys BC
                             73 ; Returns A
   00F5                      74 I2CRBYTE:
   00F5 06 08         [ 7]   75         LD      B,8
   00F7 0E 00         [ 7]   76         LD      C,0
   00F9                      77 LOOP3:
   00F9 C5            [11]   78         PUSH    BC
   00FA CD C4 00      [17]   79         CALL    I2CRBIT     ; get bit in carry flag
   00FD C1            [10]   80         POP     BC
   00FE CB 11         [ 8]   81         RL      C           ; rotate carry into bit0 of C register
   0100 10 F7         [13]   82         DJNZ    LOOP3
   0102 AF            [ 4]   83         XOR     A           ; clear carry flag              
   0103 C5            [11]   84         PUSH    BC
   0104 CD D3 00      [17]   85         CALL    I2CWBIT
   0107 C1            [10]   86         POP     BC
   0108 79            [ 4]   87         LD      A,C
   0109 C9            [10]   88         RET
                             89 ;
                             90 
                             91 ; Read 4-byte I2C Command from device into CMDBUF
                             92 ; Uses HL
                             93 ; Destroys A,BC,HL
   010A                      94 I2CRREQ:
   010A CD B3 00      [17]   95         CALL    I2CSTART
   010D 3E 11         [ 7]   96         LD      A,I2CRADR
   010F CD E4 00      [17]   97         CALL    I2CWBYTE
   0112 38 1A         [12]   98         JR      C,SKIP
   0114 CD F5 00      [17]   99         CALL    I2CRBYTE
   0117 DD 77 00      [19]  100         LD      (IX),A
   011A CD F5 00      [17]  101         CALL    I2CRBYTE
   011D DD 77 01      [19]  102         LD      (IX+1),A  
   0120 CD F5 00      [17]  103         CALL    I2CRBYTE
   0123 DD 77 02      [19]  104         LD      (IX+2),A
   0126 CD F5 00      [17]  105         CALL    I2CRBYTE
   0129 DD 77 03      [19]  106         LD      (IX+3),A
   012C 18 14         [12]  107         JR      ENDI2C
                            108     
   012E                     109 SKIP:                       ; If no device present, fake an idle response
   012E 3E 2E         [ 7]  110         LD      A,0x2e  ; '.'
   0130 DD 77 00      [19]  111         LD      (IX),A
   0133 18 0D         [12]  112         JR      ENDI2C
                            113 
   0135                     114 I2CSRESP:
   0135 F5            [11]  115         PUSH    AF
   0136 CD B3 00      [17]  116         CALL    I2CSTART
   0139 3E 10         [ 7]  117         LD      A,I2CWADR
   013B CD E4 00      [17]  118         CALL    I2CWBYTE
   013E F1            [10]  119         POP     AF
   013F CD E4 00      [17]  120         CALL    I2CWBYTE
   0142                     121 ENDI2C:
   0142 CD BA 00      [17]  122         CALL    I2CSTOP
   0145 C9            [10]  123         RET
                            124 ;
                            125 
                            126 ; Main Polling loop
                            127 ; Return carry flag if we got a valid command (not idle)
   0146                     128 POLL:
   0146 CD 0A 01      [17]  129         CALL    I2CRREQ
   0149 DD 7E 00      [19]  130         LD      A,(IX)
   014C FE 52         [ 7]  131         CP      0x52    ; 'R' - Read memory
   014E 28 1B         [12]  132         JR      Z,MREAD
   0150 FE 57         [ 7]  133         CP      0x57    ; 'W' - Write memory
   0152 28 1D         [12]  134         JR      Z,MWRITE
   0154 FE 49         [ 7]  135         CP      0x49    ; 'I' - Input from port
   0156 28 2D         [12]  136         JR      Z,PREAD
   0158 FE 4F         [ 7]  137         CP      0x4F    ; 'O' - Output from port
   015A 28 30         [12]  138         JR      Z,PWRITE
   015C FE 43         [ 7]  139         CP      0x43    ; 'C' - Call subroutine
   015E 28 3B         [12]  140         JR      Z,REMCALL
   0160 3F            [ 4]  141         CCF
   0161 C9            [10]  142         RET
   0162                     143 LOADHL:
   0162 DD 7E 01      [19]  144         LD      A,(IX+1)
   0165 67            [ 4]  145         LD      H,A
   0166 DD 7E 02      [19]  146         LD      A,(IX+2)
   0169 6F            [ 4]  147         LD      L,A
   016A C9            [10]  148         RET    
   016B                     149 MREAD:
   016B CD 7C 01      [17]  150         CALL    LOADBC
   016E 0A            [ 7]  151         LD      A,(BC)
   016F 18 25         [12]  152         JR      SRESP
   0171                     153 MWRITE:
   0171 CD 7C 01      [17]  154         CALL    LOADBC
   0174 DD 7E 03      [19]  155         LD      A,(IX+3)
   0177 02            [ 7]  156         LD      (BC),A
   0178 3E 57         [ 7]  157         LD      A,0x57  ;'W'
   017A 18 1A         [12]  158         JR      SRESP
   017C                     159 LOADBC:
   017C DD 7E 01      [19]  160         LD      A,(IX+1)
   017F 47            [ 4]  161         LD      B,A
   0180 DD 7E 02      [19]  162         LD      A,(IX+2)
   0183 4F            [ 4]  163         LD      C,A
   0184 C9            [10]  164         RET
   0185                     165 PREAD:
   0185 CD 7C 01      [17]  166         CALL    LOADBC
   0188 ED 78         [12]  167         IN      A,(C)
   018A 18 0A         [12]  168         JR      SRESP
   018C                     169 PWRITE:
   018C CD 7C 01      [17]  170         CALL    LOADBC
   018F DD 7E 03      [19]  171         LD      A,(IX+3)
   0192 ED 79         [12]  172         OUT     (C),A
   0194 3E 4F         [ 7]  173         LD      A,0x4F  ;'O'
   0196                     174 SRESP:
   0196 CD 35 01      [17]  175         CALL    I2CSRESP
   0199                     176 RHERE:
   0199 37            [ 4]  177         SCF
   019A C9            [10]  178         RET
   019B                     179 REMCALL:
   019B 21 00 00      [10]  180         LD      HL,START
   019E E5            [11]  181         PUSH    HL
   019F CD 62 01      [17]  182         CALL    LOADHL
   01A2 E9            [ 4]  183         JP      (HL)
                            184     
   01A3                     185 INIT:
   01A3 31 F0 FF      [10]  186         LD      SP,RAMADDR  ; have to set valid SP
   01A6 DD 21 F0 FF   [14]  187         LD      IX,CMDBUF   ; Easy to index command buffer
   01AA 16 00         [ 7]  188         LD      D,#0x00     ; initialize D to prevent index overflow
                            189         
   01AC CD 04 00      [17]  190         CALL    ONCE
                            191 
                            192 ; Main routine
   01AF                     193 MAIN:
   01AF CD B1 00      [17]  194         CALL    EVERY
   01B2 CD 46 01      [17]  195         CALL    POLL
   01B5 38 F8         [12]  196         JR      C,MAIN
                            197         
   01B7 01 80 01      [10]  198         LD      BC,BIGDEL
   01BA                     199 DLOOP:
   01BA 0B            [ 6]  200         DEC     BC
   01BB 79            [ 4]  201         LD      A,C
   01BC B0            [ 4]  202         OR      B
   01BD 20 FB         [12]  203         JR      NZ,DLOOP
   01BF 18 EE         [12]  204         JR      MAIN
                             19 
                             20         .bank   third   (base=IOREGW, size=0x20)
                             21         .area   third   (ABS, BANK=third)
                             22         
                             23         .include "../z80/romio_table.asm"
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
   07C0 00 01 02 03 04 05    21         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   07D0 10 11 12 13 14 15    22         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
                             23 
                             24 
