                              2 
                              3 ;--------------------------------------------------------------------------
                              4 ; TARGET-SPECIFIC DEFINITIONS
                              5 ;--------------------------------------------------------------------------
                              6 ; RAM SETTINGS
                     77F0     7 RAMADDR .equ    0x77f0      ; Start of RAM variables - need only 4 bytes here, but we have 16
                              8                             ; Stack will grow towards 0 from this point
                              9 
                             10 ;--------------------------------------------------------------------------
                             11 ; MESSAGE MACRO
                             12 ;--------------------------------------------------------------------------
                             13         .macro  MESSAGE_MACRO
                             14     	.asciz  "BY: EVAN&FRANK/DEMON DEBUGGER/2019"
                             15         .endm
                             16 
                             17 ;--------------------------------------------------------------------------
                             18 ; STARTUP MACROS
                             19 ;
                             20 ; These are called once, and can be used do any target-specific
                             21 ; initialization that is required
                             22 ;--------------------------------------------------------------------------
                             23 
                             24         .macro  STARTUP1_MACRO 
                             25         DI                  ; Disable interrupts - we don't handle them
                             26         LD      SP,RAMADDR  ; have to set valid SP
                             27 ;       YOUR SMALL CODE CAN GO HERE
                             28         .endm     
                             29 
                             30 ;--------------------------------------------------------------------------
                             31 ; EVERY MACRO
                             32 ; This is called regularly, every polling loop, and can be used do any 
                             33 ; target-specific task that is required, such as hitting a watchdog
                             34 ;--------------------------------------------------------------------------
                             35 
                             36         .macro  EVERY_MACRO  
                             37 ;       YOUR CODE CAN GO HERE
                             38         RET
                             39         .endm        
                             40 
                             41 ;--------------------------------------------------------------------------
                             42 ; ROM TEMPLATE - this defines the rom layout, and which kind of io
                             43 ;--------------------------------------------------------------------------
                             44         .include "../rom_templates/coleco-cart_romio_8000_2k.asm"
                              1 
                              2           
                     8000     3 STRTADD .equ    0x8000      ; start of chip memory mapping
                     0800     4 ROMSIZE .equ    0x0800      ; 2K ROM
                              5 
                              6         .include "../dd/dd.def"
                              1 
                     8800     2 ROMEND  .equ    STRTADD+ROMSIZE
                              3 
                              4 
                              7         .include "../io/romio.def"
                              1 ; For Demon Debugger Hardware - Rev D 
                              2 
                     87A0     3 IOREGR   .equ   STRTADD+0x07a0    ;reserved region for IO READ
                     87C0     4 IOREGW   .equ   STRTADD+0x07c0    ;reserved region for IO WRITE
                              5 
                     87A0     6 IOADD    .equ   IOREGR            ;start of region
                     87E0     7 IOEND    .equ   STRTADD+0x07e0    ;end of region
                              8 
                              9 ; TIMER SETTING
                     0180    10 BIGDEL  .equ    0x0180      ; delay factor
                             11 
                             12         ;--------------------------------------------------
                             13         ; On the ColecoVision, the start address is 0x8000
                             14         ;--------------------------------------------------
                             15         .bank   first   (base=STRTADD, size=IOADD-STRTADD)
                             16         .area   first   (ABS, BANK=first)
                             17 
   8000 AA                   18         .db	0xaa	    ; cartridge signature
   8001 55                   19     	.db	0x55
                             20     	
   8002 00 00                21     	.dw     0x0000
   8004 00 00                22     	.dw     0x0000
   8006 00 00                23     	.dw     0x0000
   8008 00 00                24     	.dw     0x0000
   800A 47 80                25     	.dw     STARTUP1
   800C C3 08 00      [10]   26     	JP      0x0008
   800F C3 10 00      [10]   27     	JP      0x0010
   8012 C3 18 00      [10]   28     	JP      0x0018
   8015 C3 20 00      [10]   29     	JP      0x0020
   8018 C3 28 00      [10]   30     	JP      0x0028
   801B C3 30 00      [10]   31     	JP      0x0030
   801E C3 38 00      [10]   32     	JP      0x0038
   8021 C3 66 00      [10]   33     	JP      0x0066
                             34     	
   0024                      35         MESSAGE_MACRO
   8024 42 59 3A 20 45 56     1     	.asciz  "BY: EVAN&FRANK/DEMON DEBUGGER/2019"
        41 4E 26 46 52 41
        4E 4B 2F 44 45 4D
        4F 4E 20 44 45 42
        55 47 47 45 52 2F
        32 30 31 39 00
                             36     	
   8047                      37 STARTUP1:  
   0047                      38         STARTUP1_MACRO
   8047 F3            [ 4]    1         DI                  ; Disable interrupts - we don't handle them
   8048 31 F0 77      [10]    2         LD      SP,RAMADDR  ; have to set valid SP
                              3 ;       YOUR SMALL CODE CAN GO HERE
                             39 
                             40         ; Entry to main routine here
                             41         .include "../dd/z80_main.asm"
                              1 ; I2C ADDRESSING
                     0011     2 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010     3 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                              4 
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 ; RAM Variables	
                              7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              8 
                     77F0     9 CMDBUF  .equ    RAMADDR     ; Need only 4 bytes of ram for command buffer
                             10 
   804B DD 21 F0 77   [14]   11         LD      IX,CMDBUF   ; Easy to index command buffer
   804F 16 00         [ 7]   12         LD      D,#0x00     ; initialize D to prevent index overflow
                             13 
                             14 ; Main routine
   8051                      15 MAIN:
   8051 CD 57 81      [17]   16         CALL    EVERY
   8054 CD FA 80      [17]   17         CALL    POLL
   8057 DA 51 80      [10]   18         JP      C,MAIN
                             19         
   805A 01 80 01      [10]   20         LD      BC,BIGDEL
   805D                      21 DLOOP:
   805D 0B            [ 6]   22         DEC     BC
   805E 79            [ 4]   23         LD      A,C
   805F B0            [ 4]   24         OR      B
   8060 C2 5D 80      [10]   25         JP      NZ,DLOOP
   8063 C3 51 80      [10]   26         JP      MAIN
                             27 
                             28 ; Delay for half a bit time
   8066                      29 I2CDELAY:
   8066 C9            [10]   30         RET     ; This is plenty
                             31 
                             32 ; I2C Start Condition
                             33 ; Uses HL
                             34 ; Destroys A
   8067                      35 I2CSTART:
   8067 CD 85 81      [17]   36         CALL    CLRSDA      
   806A CD 68 81      [17]   37         CALL    CLRSCL
   806D C9            [10]   38         RET
                             39 
                             40 ; I2C Stop Condition
                             41 ; Uses HL
                             42 ; Destroys A
   806E                      43 I2CSTOP:
   806E CD 85 81      [17]   44         CALL    CLRSDA
   8071 CD 58 81      [17]   45         CALL    SETSCL
   8074 CD 75 81      [17]   46         CALL    SETSDA
   8077 C9            [10]   47         RET
                             48 
                             49 ; I2C Read Bit routine
                             50 ; Returns bit in carry blag
                             51 ; Destroys A
   8078                      52 I2CRBIT:
   8078 CD 75 81      [17]   53         CALL    SETSDA
   807B CD 58 81      [17]   54         CALL    SETSCL
   807E CD 95 81      [17]   55         CALL    READSDA
   8081 F5            [11]   56         PUSH    AF          ; save carry flag
   8082 CD 68 81      [17]   57         CALL    CLRSCL
   8085 F1            [10]   58         POP     AF          ; rv in carry flag
   8086 C9            [10]   59         RET
                             60 
                             61 ; I2C Write Bit routine
                             62 ; Takes carry flag
                             63 ; Destroys A
   8087                      64 I2CWBIT:
   8087 30 05         [12]   65         JR      NC,DOCLR
   8089 CD 75 81      [17]   66         CALL    SETSDA
   808C 18 03         [12]   67         JR      AHEAD
   808E                      68 DOCLR:
   808E CD 85 81      [17]   69         CALL    CLRSDA
   8091                      70 AHEAD:
   8091 CD 58 81      [17]   71         CALL    SETSCL
   8094 CD 68 81      [17]   72         CALL    CLRSCL
   8097 C9            [10]   73         RET
                             74 
                             75 ; I2C Write Byte routine
                             76 ; Takes A
                             77 ; Destroys B
                             78 ; Returns carry bit
   8098                      79 I2CWBYTE:
   8098 06 08         [ 7]   80         LD      B,8
   809A                      81 ILOOP:
   809A C5            [11]   82         PUSH    BC          ; save B
   809B CB 07         [ 8]   83         RLC     A    
   809D F5            [11]   84         PUSH    AF          ; save A
   809E CD 87 80      [17]   85         CALL    I2CWBIT
   80A1 F1            [10]   86         POP     AF
   80A2 C1            [10]   87         POP     BC
   80A3 10 F5         [13]   88         DJNZ    ILOOP
   80A5 CD 78 80      [17]   89         CALL    I2CRBIT
   80A8 C9            [10]   90         RET
                             91 
                             92 ; I2C Read Byte routine
                             93 ; Destroys BC
                             94 ; Returns A
   80A9                      95 I2CRBYTE:
   80A9 06 08         [ 7]   96         LD      B,8
   80AB 0E 00         [ 7]   97         LD      C,0
   80AD                      98 LOOP3:
   80AD C5            [11]   99         PUSH    BC
   80AE CD 78 80      [17]  100         CALL    I2CRBIT     ; get bit in carry flag
   80B1 C1            [10]  101         POP     BC
   80B2 CB 11         [ 8]  102         RL      C           ; rotate carry into bit0 of C register
   80B4 10 F7         [13]  103         DJNZ    LOOP3
   80B6 AF            [ 4]  104         XOR     A           ; clear carry flag              
   80B7 C5            [11]  105         PUSH    BC
   80B8 CD 87 80      [17]  106         CALL    I2CWBIT
   80BB C1            [10]  107         POP     BC
   80BC 79            [ 4]  108         LD      A,C
   80BD C9            [10]  109         RET
                            110 ;
                            111 
                            112 ; Read 4-byte I2C Command from device into CMDBUF
                            113 ; Uses HL
                            114 ; Destroys A,BC,HL
   80BE                     115 I2CRREQ:
   80BE CD 67 80      [17]  116         CALL    I2CSTART
   80C1 3E 11         [ 7]  117         LD      A,I2CRADR
   80C3 CD 98 80      [17]  118         CALL    I2CWBYTE
   80C6 38 1A         [12]  119         JR      C,SKIP
   80C8 CD A9 80      [17]  120         CALL    I2CRBYTE
   80CB DD 77 00      [19]  121         LD      (IX),A
   80CE CD A9 80      [17]  122         CALL    I2CRBYTE
   80D1 DD 77 01      [19]  123         LD      (IX+1),A  
   80D4 CD A9 80      [17]  124         CALL    I2CRBYTE
   80D7 DD 77 02      [19]  125         LD      (IX+2),A
   80DA CD A9 80      [17]  126         CALL    I2CRBYTE
   80DD DD 77 03      [19]  127         LD      (IX+3),A
   80E0 18 14         [12]  128         JR      ENDI2C
                            129     
   80E2                     130 SKIP:                       ; If no device present, fake an idle response
   80E2 3E 2E         [ 7]  131         LD      A,0x2e  ; '.'
   80E4 DD 77 00      [19]  132         LD      (IX),A
   80E7 18 0D         [12]  133         JR      ENDI2C
                            134 
   80E9                     135 I2CSRESP:
   80E9 F5            [11]  136         PUSH    AF
   80EA CD 67 80      [17]  137         CALL    I2CSTART
   80ED 3E 10         [ 7]  138         LD      A,I2CWADR
   80EF CD 98 80      [17]  139         CALL    I2CWBYTE
   80F2 F1            [10]  140         POP     AF
   80F3 CD 98 80      [17]  141         CALL    I2CWBYTE
   80F6                     142 ENDI2C:
   80F6 CD 6E 80      [17]  143         CALL    I2CSTOP
   80F9 C9            [10]  144         RET
                            145 ;
                            146 
                            147 ; Main Polling loop
                            148 ; Return carry flag if we got a valid command (not idle)
   80FA                     149 POLL:
   80FA CD BE 80      [17]  150         CALL    I2CRREQ
   80FD DD 7E 00      [19]  151         LD      A,(IX)
   8100 FE 52         [ 7]  152         CP      0x52    ; 'R' - Read memory
   8102 28 1B         [12]  153         JR      Z,MREAD
   8104 FE 57         [ 7]  154         CP      0x57    ; 'W' - Write memory
   8106 28 1D         [12]  155         JR      Z,MWRITE
   8108 FE 49         [ 7]  156         CP      0x49    ; 'I' - Input from port
   810A 28 2D         [12]  157         JR      Z,PREAD
   810C FE 4F         [ 7]  158         CP      0x4F    ; 'O' - Output from port
   810E 28 30         [12]  159         JR      Z,PWRITE
   8110 FE 43         [ 7]  160         CP      0x43    ; 'C' - Call subroutine
   8112 28 3B         [12]  161         JR      Z,REMCALL
   8114 3F            [ 4]  162         CCF
   8115 C9            [10]  163         RET
   8116                     164 LOADHL:
   8116 DD 7E 01      [19]  165         LD      A,(IX+1)
   8119 67            [ 4]  166         LD      H,A
   811A DD 7E 02      [19]  167         LD      A,(IX+2)
   811D 6F            [ 4]  168         LD      L,A
   811E C9            [10]  169         RET    
   811F                     170 MREAD:
   811F CD 30 81      [17]  171         CALL    LOADBC
   8122 0A            [ 7]  172         LD      A,(BC)
   8123 18 25         [12]  173         JR      SRESP
   8125                     174 MWRITE:
   8125 CD 30 81      [17]  175         CALL    LOADBC
   8128 DD 7E 03      [19]  176         LD      A,(IX+3)
   812B 02            [ 7]  177         LD      (BC),A
   812C 3E 57         [ 7]  178         LD      A,0x57  ;'W'
   812E 18 1A         [12]  179         JR      SRESP
   8130                     180 LOADBC:
   8130 DD 7E 01      [19]  181         LD      A,(IX+1)
   8133 47            [ 4]  182         LD      B,A
   8134 DD 7E 02      [19]  183         LD      A,(IX+2)
   8137 4F            [ 4]  184         LD      C,A
   8138 C9            [10]  185         RET
   8139                     186 PREAD:
   8139 CD 30 81      [17]  187         CALL    LOADBC
   813C ED 78         [12]  188         IN      A,(C)
   813E 18 0A         [12]  189         JR      SRESP
   8140                     190 PWRITE:
   8140 CD 30 81      [17]  191         CALL    LOADBC
   8143 DD 7E 03      [19]  192         LD      A,(IX+3)
   8146 ED 79         [12]  193         OUT     (C),A
   8148 3E 4F         [ 7]  194         LD      A,0x4F  ;'O'
   814A                     195 SRESP:
   814A CD E9 80      [17]  196         CALL    I2CSRESP
   814D                     197 RHERE:
   814D 37            [ 4]  198         SCF
   814E C9            [10]  199         RET
   814F                     200 REMCALL:
   814F 21 47 80      [10]  201         LD      HL,STARTUP1
   8152 E5            [11]  202         PUSH    HL
   8153 CD 16 81      [17]  203         CALL    LOADHL
   8156 E9            [ 4]  204         JP      (HL)
                            205 
                             42 
   8157                      43 EVERY:
   0157                      44         EVERY_MACRO
                              1 ;       YOUR CODE CAN GO HERE
   8157 C9            [10]    2         RET
                             45 
                             46         ; Routines for romio here
                             47         .include "../io/z80_romio.asm"
                              1 
                              2 ; For Demon Debugger Hardware - Rev D 
                              3 
                              4 ; Set the SCL pin high
                              5 ; D is the global output buffer
                              6 ; Destroys A
   8158                       7 SETSCL:
   8158 7A            [ 4]    8         LD      A,D
   8159 F6 01         [ 7]    9         OR      0x01
   815B 57            [ 4]   10         LD      D,A
   815C E5            [11]   11         PUSH    HL
   815D 26 87         [ 7]   12         LD      H,#>IOREGW
   815F C6 C0         [ 7]   13         ADD     A,#<IOREGW 
   8161 6F            [ 4]   14         LD      L,A
   8162 7E            [ 7]   15         LD      A,(HL)
   8163 E1            [10]   16         POP     HL
   8164 CD 66 80      [17]   17         CALL    I2CDELAY
   8167 C9            [10]   18         RET
                             19     
                             20 ; Set the SCL pin low
                             21 ; D is the global output buffer
                             22 ; Destroys A
   8168                      23 CLRSCL:
   8168 7A            [ 4]   24         LD      A,D
   8169 E6 1E         [ 7]   25         AND     0x1E
   816B 57            [ 4]   26         LD      D,A
   816C E5            [11]   27         PUSH    HL
   816D 26 87         [ 7]   28         LD      H,#>IOREGW
   816F C6 C0         [ 7]   29         ADD     A,#<IOREGW 
   8171 6F            [ 4]   30         LD      L,A
   8172 7E            [ 7]   31         LD      A,(HL)
   8173 E1            [10]   32         POP     HL
   8174 C9            [10]   33         RET
                             34 
                             35 ; Set the DOUT pin low
                             36 ; D is the global output buffer
                             37 ; Destroys A 
   8175                      38 SETSDA:
   8175 7A            [ 4]   39         LD      A,D
   8176 E6 1D         [ 7]   40         AND     0x1D
   8178 57            [ 4]   41         LD      D,A
   8179 E5            [11]   42         PUSH    HL
   817A 26 87         [ 7]   43         LD      H,#>IOREGW
   817C C6 C0         [ 7]   44         ADD     A,#<IOREGW 
   817E 6F            [ 4]   45         LD      L,A
   817F 7E            [ 7]   46         LD      A,(HL)
   8180 E1            [10]   47         POP     HL
   8181 CD 66 80      [17]   48         CALL    I2CDELAY
   8184 C9            [10]   49         RET
                             50 
                             51 ; Set the DOUT pin high
                             52 ; D is the global output buffer
                             53 ; Destroys A  
   8185                      54 CLRSDA:
   8185 7A            [ 4]   55         LD      A,D
   8186 F6 02         [ 7]   56         OR      0x02
   8188 57            [ 4]   57         LD      D,A
   8189 E5            [11]   58         PUSH    HL
   818A 26 87         [ 7]   59         LD      H,#>IOREGW
   818C C6 C0         [ 7]   60         ADD     A,#<IOREGW 
   818E 6F            [ 4]   61         LD      L,A
   818F 7E            [ 7]   62         LD      A,(HL)
   8190 E1            [10]   63         POP     HL
   8191 CD 66 80      [17]   64         CALL    I2CDELAY
   8194 C9            [10]   65         RET
                             66 
                             67 ; Read the DIN pin 
                             68 ; returns bit in carry flag    
   8195                      69 READSDA:
   8195 7A            [ 4]   70         LD      A,D
   8196 E5            [11]   71         PUSH    HL
   8197 26 87         [ 7]   72         LD      H,#>IOREGR
   8199 C6 A0         [ 7]   73         ADD     A,#<IOREGR
   819B 6F            [ 4]   74         LD      L,A
   819C 7E            [ 7]   75         LD      A,(HL)
   819D E1            [10]   76         POP     HL
   819E CB 3F         [ 8]   77         SRL     A           ;carry flag
   81A0 C9            [10]   78         RET
                             48 
                             49         ;--------------------------------------------------
                             50         ; The romio region has a small table here
                             51         ;--------------------------------------------------
                             52         .bank   second  (base=IOADD, size=IOEND-IOADD)
                             53         .area   second  (ABS, BANK=second)
                             54         .include "../io/romio_table.asm"
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
   87A0 FF FF FF FF FF FF    22         .DB     0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
        FF FF FF FF FF FF
        FF FF FF FF
   87B0 FF FF FF FF FF FF    23         .DB     0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
        FF FF FF FF FF FF
        FF FF FF FF
                             24 
                             25         ; ROMIO WRITE Area - data is used
   87C0 00 01 02 03 04 05    26         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   87D0 10 11 12 13 14 15    27         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
                             28 
                             55 
                             56         ;--------------------------------------------------
                             57         ; There is a little more room here, which is unused
                             58         ;--------------------------------------------------
                             59         .bank   third  (base=IOREGW+0x20, size=ROMEND-IOEND)
                             60         .area   third  (ABS, BANK=third)
                             61 
                             62         .end
