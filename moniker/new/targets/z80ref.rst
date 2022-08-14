                              2 
                              3 ;--------------------------------------------------------------------------
                              4 ; TARGET-SPECIFIC DEFINITIONS
                              5 ;--------------------------------------------------------------------------
                              6 ; RAM SETTINGS
                     FFF0     7 RAMADDR .equ    0xfff0      ; Start of RAM variables - need only 4 bytes here, but we have 16
                              8                             ; Stack will grow towards 0 from this point
                              9 
                             10 ;--------------------------------------------------------------------------
                             11 ; IRQ HANDLER
                             12 ;--------------------------------------------------------------------------
                             13         .macro  IRQ_MACRO
                             14         RETI
                             15         .endm
                             16 
                             17 ;--------------------------------------------------------------------------
                             18 ; NMI HANDLER
                             19 ;--------------------------------------------------------------------------
                             20         .macro  NMI_MACRO
                             21         RETN
                             22         .endm
                             23 
                             24 ;--------------------------------------------------------------------------
                             25 ; STARTUP MACROS
                             26 ;
                             27 ; These are called once, and can be used do any target-specific
                             28 ; initialization that is required
                             29 ;
                             30 ; On the Z80, it is split into two.  This is because STARTUP1_MACRO is 
                             31 ; usually place into a space-limited region.
                             32 ; It's best to expand STARTUP2_MACRO and leave STARTUP1_MACRO alone.
                             33 ;--------------------------------------------------------------------------
                             34 
                             35         .macro  STARTUP1_MACRO 
                             36         DI                  ; Disable interrupts - we don't handle them
                             37         LD      SP,RAMADDR  ; have to set valid SP
                             38 ;       YOUR SMALL CODE CAN GO HERE
                             39         .endm
                             40 
                             41         .macro  STARTUP2_MACRO 
                             42 ;       YOUR CODE CAN GO HERE
                             43         .endm        
                             44 
                             45 ;--------------------------------------------------------------------------
                             46 ; EVERY MACRO
                             47 ; This is called regularly, every polling loop, and can be used do any 
                             48 ; target-specific task that is required, such as hitting a watchdog
                             49 ;--------------------------------------------------------------------------
                             50 
                             51         .macro  EVERY_MACRO  
                             52 ;       YOUR CODE CAN GO HERE
                             53         RET
                             54         .endm        
                             55 
                             56 ;--------------------------------------------------------------------------
                             57 ; ROM TEMPLATE - this defines the rom layout, and which kind of io
                             58 ;--------------------------------------------------------------------------
                             59         .include "../rom_templates/z80_irq_romio_0000_2k.asm"
                              1 
                              2 
                              3           
                     0000     4 STRTADD .equ    0x0000      ; start of chip memory mapping
                     0800     5 ROMSIZE .equ    0x0800      ; 2K ROM
                              6 
                              7         .include "../dd/dd.def"
                              1 
                     0800     2 ROMEND  .equ    STRTADD+ROMSIZE
                              3 
                              4 
                              8         .include "../dd/z80.def"
                              1 ; Same for all Z80s
                     0038     2 IRQADD  .equ    0x0038      ; location of IRQ handler
                     0066     3 NMIADD  .equ    0x0066      ; location of NMI handler
                              9         .include "../io/romio.def"
                              1 ; For Demon Debugger Hardware - Rev D 
                              2 
                     07A0     3 IOREGR   .equ   STRTADD+0x07a0    ;reserved region for IO READ
                     07C0     4 IOREGW   .equ   STRTADD+0x07c0    ;reserved region for IO WRITE
                              5 
                     07A0     6 IOADD    .equ   IOREGR            ;start of region
                     07E0     7 IOEND    .equ   STRTADD+0x07e0    ;end of region
                              8 
                              9 ; 
                             10 ; For Demon Debugger Hardware - Rev D 
                             11 ;
                             12 ; In earlier hardware designs, I tried to capture the address bus bits on a 
                             13 ; read cycle, to use to write to the Arduino.  But it turns out it is impossible
                             14 ; to know exactly when to sample these address bits across all platforms, designs, and 
                             15 ; clock speeds
                             16 ;
                             17 ; The solution I came up with was to make sure the data bus contains the same information
                             18 ; as the lower address bus during these read cycles, so that I can sample the data bus just like the 
                             19 ; CPU would.
                             20 ;
                             21 ; This block of memory, starting at 0x07c0, is filled with consecutive integers.
                             22 ; When the CPU reads from a location, the data bus matches the lower bits of the address bus.  
                             23 ; And the data bus read by the CPU is also written to the Arduino.
                             24 ; 
                             25 ; Note: Currently, only the bottom two bits are used, but reserving the memory
                             26 ; this way insures that up to 5 bits could be used 
                             27 ; 
                             28         ;.macro  ROMIO_TABLE_MACRO
                             29         ;.bank   iowritebank   (base=IOREGW, size=0x20)
                             30         ;.area   iowritearea   (BANK=iowritebank)
                             31 
                             32         ;.DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
                             33         ;.DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
                             34         ;.endm
                             10 
                             11 ; TIMER SETTING
                     0180    12 BIGDEL  .equ    0x0180      ; delay factor
                             13 
                             14         ;--------------------------------------------------
                             15         ; On the Z80, the start address is 0x0000
                             16         ; but the IRQ handler is at 0x0038
                             17         ; So, we put a small but of startup code here,
                             18         ; and then jump to after the NMI handler for more
                             19         ;--------------------------------------------------
                             20         .bank   first   (base=STRTADD, size=IRQADD-STRTADD)
                             21         .area   first   (ABS, BANK=first)
   0000                      22 STARTUP1:
   0000                      23         STARTUP1_MACRO
   0000 F3            [ 4]    1         DI                  ; Disable interrupts - we don't handle them
   0001 31 F0 FF      [10]    2         LD      SP,RAMADDR  ; have to set valid SP
                              3 ;       YOUR SMALL CODE CAN GO HERE
   0004 C3 68 00      [10]   24         JP      STARTUP2
                             25 
                             26         ;--------------------------------------------------
                             27         ; This region is reserved for the IRQ handler
                             28         ;--------------------------------------------------
                             29         .bank   second  (base=IRQADD, size=NMIADD-IRQADD)
                             30         .area   second  (ABS, BANK=second)
   0038                      31 IRQ:
   0000                      32         IRQ_MACRO
   0038 ED 4D         [14]    1         RETI
                             33 
                             34         ;--------------------------------------------------
                             35         ; This region starts with the NMI handler, and then
                             36         ; continues with the rest of code immediately after
                             37         ; It can go until the start of the romio region
                             38         ;--------------------------------------------------
                             39         .bank   third  (base=NMIADD, size=IOADD-NMIADD)
                             40         .area   third  (ABS, BANK=third)
   0066                      41 NMI:
   0000                      42         NMI_MACRO
   0066 ED 45         [14]    1         RETN
                             43 
   0068                      44 STARTUP2:
   0002                      45         STARTUP2_MACRO
                              1 ;       YOUR CODE CAN GO HERE
                             46 
                             47         ; Entry to main routine here
                             48         .include "../dd/z80_main.asm"
                              1 ; I2C ADDRESSING
                     0011     2 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010     3 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                              4 
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 ; RAM Variables	
                              7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              8 
                     FFF0     9 CMDBUF  .equ    RAMADDR     ; Need only 4 bytes of ram for command buffer
                             10 
   0068 DD 21 F0 FF   [14]   11         LD      IX,CMDBUF   ; Easy to index command buffer
   006C 16 00         [ 7]   12         LD      D,#0x00     ; initialize D to prevent index overflow
                             13 
                             14 ; Main routine
   006E                      15 MAIN:
   006E CD 74 01      [17]   16         CALL    EVERY
   0071 CD 17 01      [17]   17         CALL    POLL
   0074 DA 6E 00      [10]   18         JP      C,MAIN
                             19         
   0077 01 80 01      [10]   20         LD      BC,BIGDEL
   007A                      21 DLOOP:
   007A 0B            [ 6]   22         DEC     BC
   007B 79            [ 4]   23         LD      A,C
   007C B0            [ 4]   24         OR      B
   007D C2 7A 00      [10]   25         JP      NZ,DLOOP
   0080 C3 6E 00      [10]   26         JP      MAIN
                             27 
                             28 ; Delay for half a bit time
   0083                      29 I2CDELAY:
   0083 C9            [10]   30         RET     ; This is plenty
                             31 
                             32 ; I2C Start Condition
                             33 ; Uses HL
                             34 ; Destroys A
   0084                      35 I2CSTART:
   0084 CD A2 01      [17]   36         CALL    CLRSDA      
   0087 CD 85 01      [17]   37         CALL    CLRSCL
   008A C9            [10]   38         RET
                             39 
                             40 ; I2C Stop Condition
                             41 ; Uses HL
                             42 ; Destroys A
   008B                      43 I2CSTOP:
   008B CD A2 01      [17]   44         CALL    CLRSDA
   008E CD 75 01      [17]   45         CALL    SETSCL
   0091 CD 92 01      [17]   46         CALL    SETSDA
   0094 C9            [10]   47         RET
                             48 
                             49 ; I2C Read Bit routine
                             50 ; Returns bit in carry blag
                             51 ; Destroys A
   0095                      52 I2CRBIT:
   0095 CD 92 01      [17]   53         CALL    SETSDA
   0098 CD 75 01      [17]   54         CALL    SETSCL
   009B CD B2 01      [17]   55         CALL    READSDA
   009E F5            [11]   56         PUSH    AF          ; save carry flag
   009F CD 85 01      [17]   57         CALL    CLRSCL
   00A2 F1            [10]   58         POP     AF          ; rv in carry flag
   00A3 C9            [10]   59         RET
                             60 
                             61 ; I2C Write Bit routine
                             62 ; Takes carry flag
                             63 ; Destroys A
   00A4                      64 I2CWBIT:
   00A4 30 05         [12]   65         JR      NC,DOCLR
   00A6 CD 92 01      [17]   66         CALL    SETSDA
   00A9 18 03         [12]   67         JR      AHEAD
   00AB                      68 DOCLR:
   00AB CD A2 01      [17]   69         CALL    CLRSDA
   00AE                      70 AHEAD:
   00AE CD 75 01      [17]   71         CALL    SETSCL
   00B1 CD 85 01      [17]   72         CALL    CLRSCL
   00B4 C9            [10]   73         RET
                             74 
                             75 ; I2C Write Byte routine
                             76 ; Takes A
                             77 ; Destroys B
                             78 ; Returns carry bit
   00B5                      79 I2CWBYTE:
   00B5 06 08         [ 7]   80         LD      B,8
   00B7                      81 ILOOP:
   00B7 C5            [11]   82         PUSH    BC          ; save B
   00B8 CB 07         [ 8]   83         RLC     A    
   00BA F5            [11]   84         PUSH    AF          ; save A
   00BB CD A4 00      [17]   85         CALL    I2CWBIT
   00BE F1            [10]   86         POP     AF
   00BF C1            [10]   87         POP     BC
   00C0 10 F5         [13]   88         DJNZ    ILOOP
   00C2 CD 95 00      [17]   89         CALL    I2CRBIT
   00C5 C9            [10]   90         RET
                             91 
                             92 ; I2C Read Byte routine
                             93 ; Destroys BC
                             94 ; Returns A
   00C6                      95 I2CRBYTE:
   00C6 06 08         [ 7]   96         LD      B,8
   00C8 0E 00         [ 7]   97         LD      C,0
   00CA                      98 LOOP3:
   00CA C5            [11]   99         PUSH    BC
   00CB CD 95 00      [17]  100         CALL    I2CRBIT     ; get bit in carry flag
   00CE C1            [10]  101         POP     BC
   00CF CB 11         [ 8]  102         RL      C           ; rotate carry into bit0 of C register
   00D1 10 F7         [13]  103         DJNZ    LOOP3
   00D3 AF            [ 4]  104         XOR     A           ; clear carry flag              
   00D4 C5            [11]  105         PUSH    BC
   00D5 CD A4 00      [17]  106         CALL    I2CWBIT
   00D8 C1            [10]  107         POP     BC
   00D9 79            [ 4]  108         LD      A,C
   00DA C9            [10]  109         RET
                            110 ;
                            111 
                            112 ; Read 4-byte I2C Command from device into CMDBUF
                            113 ; Uses HL
                            114 ; Destroys A,BC,HL
   00DB                     115 I2CRREQ:
   00DB CD 84 00      [17]  116         CALL    I2CSTART
   00DE 3E 11         [ 7]  117         LD      A,I2CRADR
   00E0 CD B5 00      [17]  118         CALL    I2CWBYTE
   00E3 38 1A         [12]  119         JR      C,SKIP
   00E5 CD C6 00      [17]  120         CALL    I2CRBYTE
   00E8 DD 77 00      [19]  121         LD      (IX),A
   00EB CD C6 00      [17]  122         CALL    I2CRBYTE
   00EE DD 77 01      [19]  123         LD      (IX+1),A  
   00F1 CD C6 00      [17]  124         CALL    I2CRBYTE
   00F4 DD 77 02      [19]  125         LD      (IX+2),A
   00F7 CD C6 00      [17]  126         CALL    I2CRBYTE
   00FA DD 77 03      [19]  127         LD      (IX+3),A
   00FD 18 14         [12]  128         JR      ENDI2C
                            129     
   00FF                     130 SKIP:                       ; If no device present, fake an idle response
   00FF 3E 2E         [ 7]  131         LD      A,0x2e  ; '.'
   0101 DD 77 00      [19]  132         LD      (IX),A
   0104 18 0D         [12]  133         JR      ENDI2C
                            134 
   0106                     135 I2CSRESP:
   0106 F5            [11]  136         PUSH    AF
   0107 CD 84 00      [17]  137         CALL    I2CSTART
   010A 3E 10         [ 7]  138         LD      A,I2CWADR
   010C CD B5 00      [17]  139         CALL    I2CWBYTE
   010F F1            [10]  140         POP     AF
   0110 CD B5 00      [17]  141         CALL    I2CWBYTE
   0113                     142 ENDI2C:
   0113 CD 8B 00      [17]  143         CALL    I2CSTOP
   0116 C9            [10]  144         RET
                            145 ;
                            146 
                            147 ; Main Polling loop
                            148 ; Return carry flag if we got a valid command (not idle)
   0117                     149 POLL:
   0117 CD DB 00      [17]  150         CALL    I2CRREQ
   011A DD 7E 00      [19]  151         LD      A,(IX)
   011D FE 52         [ 7]  152         CP      0x52    ; 'R' - Read memory
   011F 28 1B         [12]  153         JR      Z,MREAD
   0121 FE 57         [ 7]  154         CP      0x57    ; 'W' - Write memory
   0123 28 1D         [12]  155         JR      Z,MWRITE
   0125 FE 49         [ 7]  156         CP      0x49    ; 'I' - Input from port
   0127 28 2D         [12]  157         JR      Z,PREAD
   0129 FE 4F         [ 7]  158         CP      0x4F    ; 'O' - Output from port
   012B 28 30         [12]  159         JR      Z,PWRITE
   012D FE 43         [ 7]  160         CP      0x43    ; 'C' - Call subroutine
   012F 28 3B         [12]  161         JR      Z,REMCALL
   0131 3F            [ 4]  162         CCF
   0132 C9            [10]  163         RET
   0133                     164 LOADHL:
   0133 DD 7E 01      [19]  165         LD      A,(IX+1)
   0136 67            [ 4]  166         LD      H,A
   0137 DD 7E 02      [19]  167         LD      A,(IX+2)
   013A 6F            [ 4]  168         LD      L,A
   013B C9            [10]  169         RET    
   013C                     170 MREAD:
   013C CD 4D 01      [17]  171         CALL    LOADBC
   013F 0A            [ 7]  172         LD      A,(BC)
   0140 18 25         [12]  173         JR      SRESP
   0142                     174 MWRITE:
   0142 CD 4D 01      [17]  175         CALL    LOADBC
   0145 DD 7E 03      [19]  176         LD      A,(IX+3)
   0148 02            [ 7]  177         LD      (BC),A
   0149 3E 57         [ 7]  178         LD      A,0x57  ;'W'
   014B 18 1A         [12]  179         JR      SRESP
   014D                     180 LOADBC:
   014D DD 7E 01      [19]  181         LD      A,(IX+1)
   0150 47            [ 4]  182         LD      B,A
   0151 DD 7E 02      [19]  183         LD      A,(IX+2)
   0154 4F            [ 4]  184         LD      C,A
   0155 C9            [10]  185         RET
   0156                     186 PREAD:
   0156 CD 4D 01      [17]  187         CALL    LOADBC
   0159 ED 78         [12]  188         IN      A,(C)
   015B 18 0A         [12]  189         JR      SRESP
   015D                     190 PWRITE:
   015D CD 4D 01      [17]  191         CALL    LOADBC
   0160 DD 7E 03      [19]  192         LD      A,(IX+3)
   0163 ED 79         [12]  193         OUT     (C),A
   0165 3E 4F         [ 7]  194         LD      A,0x4F  ;'O'
   0167                     195 SRESP:
   0167 CD 06 01      [17]  196         CALL    I2CSRESP
   016A                     197 RHERE:
   016A 37            [ 4]  198         SCF
   016B C9            [10]  199         RET
   016C                     200 REMCALL:
   016C 21 00 00      [10]  201         LD      HL,STARTUP1
   016F E5            [11]  202         PUSH    HL
   0170 CD 33 01      [17]  203         CALL    LOADHL
   0173 E9            [ 4]  204         JP      (HL)
                            205 
                             49 
   0174                      50 EVERY:
   010E                      51         EVERY_MACRO
                              1 ;       YOUR CODE CAN GO HERE
   0174 C9            [10]    2         RET
                             52 
                             53         ; Routines for romio here
                             54         .include "../io/z80_romio.asm"
                              1 
                              2 ; For Demon Debugger Hardware - Rev D 
                              3 
                              4 ; Set the SCL pin high
                              5 ; D is the global output buffer
                              6 ; Destroys A
   0175                       7 SETSCL:
   0175 7A            [ 4]    8         LD      A,D
   0176 F6 01         [ 7]    9         OR      0x01
   0178 57            [ 4]   10         LD      D,A
   0179 E5            [11]   11         PUSH    HL
   017A 26 07         [ 7]   12         LD      H,#>IOREGW
   017C C6 C0         [ 7]   13         ADD     A,#<IOREGW 
   017E 6F            [ 4]   14         LD      L,A
   017F 7E            [ 7]   15         LD      A,(HL)
   0180 E1            [10]   16         POP     HL
   0181 CD 83 00      [17]   17         CALL    I2CDELAY
   0184 C9            [10]   18         RET
                             19     
                             20 ; Set the SCL pin low
                             21 ; D is the global output buffer
                             22 ; Destroys A
   0185                      23 CLRSCL:
   0185 7A            [ 4]   24         LD      A,D
   0186 E6 1E         [ 7]   25         AND     0x1E
   0188 57            [ 4]   26         LD      D,A
   0189 E5            [11]   27         PUSH    HL
   018A 26 07         [ 7]   28         LD      H,#>IOREGW
   018C C6 C0         [ 7]   29         ADD     A,#<IOREGW 
   018E 6F            [ 4]   30         LD      L,A
   018F 7E            [ 7]   31         LD      A,(HL)
   0190 E1            [10]   32         POP     HL
   0191 C9            [10]   33         RET
                             34 
                             35 ; Set the DOUT pin low
                             36 ; D is the global output buffer
                             37 ; Destroys A 
   0192                      38 SETSDA:
   0192 7A            [ 4]   39         LD      A,D
   0193 E6 1D         [ 7]   40         AND     0x1D
   0195 57            [ 4]   41         LD      D,A
   0196 E5            [11]   42         PUSH    HL
   0197 26 07         [ 7]   43         LD      H,#>IOREGW
   0199 C6 C0         [ 7]   44         ADD     A,#<IOREGW 
   019B 6F            [ 4]   45         LD      L,A
   019C 7E            [ 7]   46         LD      A,(HL)
   019D E1            [10]   47         POP     HL
   019E CD 83 00      [17]   48         CALL    I2CDELAY
   01A1 C9            [10]   49         RET
                             50 
                             51 ; Set the DOUT pin high
                             52 ; D is the global output buffer
                             53 ; Destroys A  
   01A2                      54 CLRSDA:
   01A2 7A            [ 4]   55         LD      A,D
   01A3 F6 02         [ 7]   56         OR      0x02
   01A5 57            [ 4]   57         LD      D,A
   01A6 E5            [11]   58         PUSH    HL
   01A7 26 07         [ 7]   59         LD      H,#>IOREGW
   01A9 C6 C0         [ 7]   60         ADD     A,#<IOREGW 
   01AB 6F            [ 4]   61         LD      L,A
   01AC 7E            [ 7]   62         LD      A,(HL)
   01AD E1            [10]   63         POP     HL
   01AE CD 83 00      [17]   64         CALL    I2CDELAY
   01B1 C9            [10]   65         RET
                             66 
                             67 ; Read the DIN pin 
                             68 ; returns bit in carry flag    
   01B2                      69 READSDA:
   01B2 7A            [ 4]   70         LD      A,D
   01B3 E5            [11]   71         PUSH    HL
   01B4 26 07         [ 7]   72         LD      H,#>IOREGR
   01B6 C6 A0         [ 7]   73         ADD     A,#<IOREGR
   01B8 6F            [ 4]   74         LD      L,A
   01B9 7E            [ 7]   75         LD      A,(HL)
   01BA E1            [10]   76         POP     HL
   01BB CB 3F         [ 8]   77         SRL     A           ;carry flag
   01BD C9            [10]   78         RET
                             55 
                             56         ;--------------------------------------------------
                             57         ; The romio write region has a small table here
                             58         ;--------------------------------------------------
                             59         .bank   fourth  (base=IOREGW, size=IOEND-IOREGW)
                             60         .area   fourth  (ABS, BANK=fourth)
                             61         .include "../io/romio_table.asm"
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
                             21         ;.bank   iowritebank   (base=IOREGW, size=0x20)
                             22         ;.area   iowritearea   (BANK=iowritebank)
                             23 
   07C0 00 01 02 03 04 05    24         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   07D0 10 11 12 13 14 15    25         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
                             26 
                             62 
                             63         ;--------------------------------------------------
                             64         ; There is a little more room here, which is unused
                             65         ;--------------------------------------------------
                             66         .bank   fifth  (base=IOEND, size=ROMEND-IOEND)
                             67         .area   fifth  (ABS, BANK=fifth)
                             68 
                             69         .end
