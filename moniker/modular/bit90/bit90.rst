                              1 
                              2         .include "settings.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; You will need to adjust these variables for different targets
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                              5 ; RAM SETTINGS
                              6 
                     77F0     7 RAMADDR .equ    0x77f0      ; Start of RAM variables - need only 4 bytes here, but we have 16
                              8 
                              9 ; ROM SETTINGS - usually the first 2K of memory for z80
                             10 
                     8000    11 STRTADD .equ    0x8000      ; start of chip memory mapping
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
                     87A0     3 IOREGR   .equ   STRTADD+0x07a0    ;reserved region for IO READ
                     87C0     4 IOREGW   .equ   STRTADD+0x07c0    ;reserved region for IO WRITE
                              5 
                     87A0     6 IOADD    .equ   IOREGR            ;start of region
                              4 
                              5         ; This section must end before the IO Region
                              6         .bank   first   (base=STRTADD, size=IOADD-STRTADD)
                              7         .area   first   (ABS, BANK=first)
                              8 
                              9         .include "cartheader.asm" 
                              1 
   8000 AA                    2        	.db	0xaa	    ; cartridge signature
   8001 55                    3     	.db	0x55
                              4     	
   8002 00 00                 5     	.dw     0x0000
   8004 00 00                 6     	.dw     0x0000
   8006 00 00                 7     	.dw     0x0000
   8008 00 00                 8     	.dw     0x0000
   800A 46 80                 9     	.dw     START
   800C C3 08 00      [10]   10     	JP      0x0008
   800F C3 10 00      [10]   11     	JP      0x0010
   8012 C3 18 00      [10]   12     	JP      0x0018
   8015 C3 20 00      [10]   13     	JP      0x0020
   8018 C3 28 00      [10]   14     	JP      0x0028
   801B C3 30 00      [10]   15     	JP      0x0030
   801E C3 38 00      [10]   16     	JP      0x0038
   8021 C3 66 00      [10]   17     	JP      0x0066
                             18     	
   8024 42 59 3A 20 45 56    19     	.ascii  "BY: EVAN&FRANK/DEMON DEBUGGER/2019"
        41 4E 26 46 52 41
        4E 4B 2F 44 45 4D
        4F 4E 20 44 45 42
        55 47 47 45 52 2F
        32 30 31 39
                             20     	
   8046 F3            [ 4]   21 START:  DI                  ; Disable interrupts - we don't handle them
   8047 C3 84 81      [10]   22         JP      INIT        ; go to initialization code
                             23 
                             10 
                             11         .include "../z80/romio.asm" 
                              1 
                              2 ; For Demon Debugger Hardware - Rev D 
                              3 
                              4 ; Set the SCL pin high
                              5 ; D is the global output buffer
                              6 ; Destroys A
   804A                       7 SETSCL:
   804A 7A            [ 4]    8         LD      A,D
   804B F6 01         [ 7]    9         OR      0x01
   804D 57            [ 4]   10         LD      D,A
   804E E5            [11]   11         PUSH    HL
   804F 26 87         [ 7]   12         LD      H,#>IOREGW
   8051 C6 C0         [ 7]   13         ADD     A,#<IOREGW 
   8053 6F            [ 4]   14         LD      L,A
   8054 7E            [ 7]   15         LD      A,(HL)
   8055 E1            [10]   16         POP     HL
   8056 CD 93 80      [17]   17         CALL    I2CDELAY
   8059 C9            [10]   18         RET
                             19     
                             20 ; Set the SCL pin low
                             21 ; D is the global output buffer
                             22 ; Destroys A
   805A                      23 CLRSCL:
   805A 7A            [ 4]   24         LD      A,D
   805B E6 1E         [ 7]   25         AND     0x1E
   805D 57            [ 4]   26         LD      D,A
   805E E5            [11]   27         PUSH    HL
   805F 26 87         [ 7]   28         LD      H,#>IOREGW
   8061 C6 C0         [ 7]   29         ADD     A,#<IOREGW 
   8063 6F            [ 4]   30         LD      L,A
   8064 7E            [ 7]   31         LD      A,(HL)
   8065 E1            [10]   32         POP     HL
   8066 C9            [10]   33         RET
                             34 
                             35 ; Set the DOUT pin low
                             36 ; D is the global output buffer
                             37 ; Destroys A 
   8067                      38 SETSDA:
   8067 7A            [ 4]   39         LD      A,D
   8068 E6 1D         [ 7]   40         AND     0x1D
   806A 57            [ 4]   41         LD      D,A
   806B E5            [11]   42         PUSH    HL
   806C 26 87         [ 7]   43         LD      H,#>IOREGW
   806E C6 C0         [ 7]   44         ADD     A,#<IOREGW 
   8070 6F            [ 4]   45         LD      L,A
   8071 7E            [ 7]   46         LD      A,(HL)
   8072 E1            [10]   47         POP     HL
   8073 CD 93 80      [17]   48         CALL    I2CDELAY
   8076 C9            [10]   49         RET
                             50 
                             51 ; Set the DOUT pin high
                             52 ; D is the global output buffer
                             53 ; Destroys A  
   8077                      54 CLRSDA:
   8077 7A            [ 4]   55         LD      A,D
   8078 F6 02         [ 7]   56         OR      0x02
   807A 57            [ 4]   57         LD      D,A
   807B E5            [11]   58         PUSH    HL
   807C 26 87         [ 7]   59         LD      H,#>IOREGW
   807E C6 C0         [ 7]   60         ADD     A,#<IOREGW 
   8080 6F            [ 4]   61         LD      L,A
   8081 7E            [ 7]   62         LD      A,(HL)
   8082 E1            [10]   63         POP     HL
   8083 CD 93 80      [17]   64         CALL    I2CDELAY
   8086 C9            [10]   65         RET
                             66 
                             67 ; Read the DIN pin 
                             68 ; returns bit in carry flag    
   8087                      69 READSDA:
   8087 7A            [ 4]   70         LD      A,D
   8088 E5            [11]   71         PUSH    HL
   8089 26 87         [ 7]   72         LD      H,#>IOREGR
   808B C6 A0         [ 7]   73         ADD     A,#<IOREGR
   808D 6F            [ 4]   74         LD      L,A
   808E 7E            [ 7]   75         LD      A,(HL)
   808F E1            [10]   76         POP     HL
   8090 CB 3F         [ 8]   77         SRL     A           ;carry flag
   8092 C9            [10]   78         RET
                             12         .include "mainloop.asm"
                              1 
                              2 ; Delay for half a bit time
   8093                       3 I2CDELAY:
   8093 C9            [10]    4         RET     ; This is plenty
                              5 
                              6 ; I2C Start Condition
                              7 ; Uses HL
                              8 ; Destroys A
   8094                       9 I2CSTART:
   8094 CD 77 80      [17]   10         CALL    CLRSDA      
   8097 CD 5A 80      [17]   11         CALL    CLRSCL
   809A C9            [10]   12         RET
                             13 
                             14 ; I2C Stop Condition
                             15 ; Uses HL
                             16 ; Destroys A
   809B                      17 I2CSTOP:
   809B CD 77 80      [17]   18         CALL    CLRSDA
   809E CD 4A 80      [17]   19         CALL    SETSCL
   80A1 CD 67 80      [17]   20         CALL    SETSDA
   80A4 C9            [10]   21         RET
                             22 
                             23 ; I2C Read Bit routine
                             24 ; Returns bit in carry blag
                             25 ; Destroys A
   80A5                      26 I2CRBIT:
   80A5 CD 67 80      [17]   27         CALL    SETSDA
   80A8 CD 4A 80      [17]   28         CALL    SETSCL
   80AB CD 87 80      [17]   29         CALL    READSDA
   80AE F5            [11]   30         PUSH    AF          ; save carry flag
   80AF CD 5A 80      [17]   31         CALL    CLRSCL
   80B2 F1            [10]   32         POP     AF          ; rv in carry flag
   80B3 C9            [10]   33         RET
                             34 
                             35 ; I2C Write Bit routine
                             36 ; Takes carry flag
                             37 ; Destroys A
   80B4                      38 I2CWBIT:
   80B4 30 05         [12]   39         JR      NC,DOCLR
   80B6 CD 67 80      [17]   40         CALL    SETSDA
   80B9 18 03         [12]   41         JR      AHEAD
   80BB                      42 DOCLR:
   80BB CD 77 80      [17]   43         CALL    CLRSDA
   80BE                      44 AHEAD:
   80BE CD 4A 80      [17]   45         CALL    SETSCL
   80C1 CD 5A 80      [17]   46         CALL    CLRSCL
   80C4 C9            [10]   47         RET
                             48 
                             49 ; I2C Write Byte routine
                             50 ; Takes A
                             51 ; Destroys B
                             52 ; Returns carry bit
   80C5                      53 I2CWBYTE:
   80C5 06 08         [ 7]   54         LD      B,8
   80C7                      55 ILOOP:
   80C7 C5            [11]   56         PUSH    BC          ; save B
   80C8 CB 07         [ 8]   57         RLC     A    
   80CA F5            [11]   58         PUSH    AF          ; save A
   80CB CD B4 80      [17]   59         CALL    I2CWBIT
   80CE F1            [10]   60         POP     AF
   80CF C1            [10]   61         POP     BC
   80D0 10 F5         [13]   62         DJNZ    ILOOP
   80D2 CD A5 80      [17]   63         CALL    I2CRBIT
   80D5 C9            [10]   64         RET
                             65 
                             66 ; I2C Read Byte routine
                             67 ; Destroys BC
                             68 ; Returns A
   80D6                      69 I2CRBYTE:
   80D6 06 08         [ 7]   70         LD      B,8
   80D8 0E 00         [ 7]   71         LD      C,0
   80DA                      72 LOOP3:
   80DA C5            [11]   73         PUSH    BC
   80DB CD A5 80      [17]   74         CALL    I2CRBIT     ; get bit in carry flag
   80DE C1            [10]   75         POP     BC
   80DF CB 11         [ 8]   76         RL      C           ; rotate carry into bit0 of C register
   80E1 10 F7         [13]   77         DJNZ    LOOP3
   80E3 AF            [ 4]   78         XOR     A           ; clear carry flag              
   80E4 C5            [11]   79         PUSH    BC
   80E5 CD B4 80      [17]   80         CALL    I2CWBIT
   80E8 C1            [10]   81         POP     BC
   80E9 79            [ 4]   82         LD      A,C
   80EA C9            [10]   83         RET
                             84 ;
                             85 
                             86 ; Read 4-byte I2C Command from device into CMDBUF
                             87 ; Uses HL
                             88 ; Destroys A,BC,HL
   80EB                      89 I2CRREQ:
   80EB CD 94 80      [17]   90         CALL    I2CSTART
   80EE 3E 11         [ 7]   91         LD      A,I2CRADR
   80F0 CD C5 80      [17]   92         CALL    I2CWBYTE
   80F3 38 1A         [12]   93         JR      C,SKIP
   80F5 CD D6 80      [17]   94         CALL    I2CRBYTE
   80F8 DD 77 00      [19]   95         LD      (IX),A
   80FB CD D6 80      [17]   96         CALL    I2CRBYTE
   80FE DD 77 01      [19]   97         LD      (IX+1),A  
   8101 CD D6 80      [17]   98         CALL    I2CRBYTE
   8104 DD 77 02      [19]   99         LD      (IX+2),A
   8107 CD D6 80      [17]  100         CALL    I2CRBYTE
   810A DD 77 03      [19]  101         LD      (IX+3),A
   810D 18 14         [12]  102         JR      ENDI2C
                            103     
   810F                     104 SKIP:                       ; If no device present, fake an idle response
   810F 3E 2E         [ 7]  105         LD      A,0x2e  ; '.'
   8111 DD 77 00      [19]  106         LD      (IX),A
   8114 18 0D         [12]  107         JR      ENDI2C
                            108 
   8116                     109 I2CSRESP:
   8116 F5            [11]  110         PUSH    AF
   8117 CD 94 80      [17]  111         CALL    I2CSTART
   811A 3E 10         [ 7]  112         LD      A,I2CWADR
   811C CD C5 80      [17]  113         CALL    I2CWBYTE
   811F F1            [10]  114         POP     AF
   8120 CD C5 80      [17]  115         CALL    I2CWBYTE
   8123                     116 ENDI2C:
   8123 CD 9B 80      [17]  117         CALL    I2CSTOP
   8126 C9            [10]  118         RET
                            119 ;
                            120 
                            121 ; Main Polling loop
                            122 ; Return carry flag if we got a valid command (not idle)
   8127                     123 POLL:
   8127 CD EB 80      [17]  124         CALL    I2CRREQ
   812A DD 7E 00      [19]  125         LD      A,(IX)
   812D FE 52         [ 7]  126         CP      0x52    ; 'R' - Read memory
   812F 28 1B         [12]  127         JR      Z,MREAD
   8131 FE 57         [ 7]  128         CP      0x57    ; 'W' - Write memory
   8133 28 1D         [12]  129         JR      Z,MWRITE
   8135 FE 49         [ 7]  130         CP      0x49    ; 'I' - Input from port
   8137 28 2D         [12]  131         JR      Z,PREAD
   8139 FE 4F         [ 7]  132         CP      0x4F    ; 'O' - Output from port
   813B 28 30         [12]  133         JR      Z,PWRITE
   813D FE 43         [ 7]  134         CP      0x43    ; 'C' - Call subroutine
   813F 28 3B         [12]  135         JR      Z,REMCALL
   8141 3F            [ 4]  136         CCF
   8142 C9            [10]  137         RET
   8143                     138 LOADHL:
   8143 DD 7E 01      [19]  139         LD      A,(IX+1)
   8146 67            [ 4]  140         LD      H,A
   8147 DD 7E 02      [19]  141         LD      A,(IX+2)
   814A 6F            [ 4]  142         LD      L,A
   814B C9            [10]  143         RET    
   814C                     144 MREAD:
   814C CD 5D 81      [17]  145         CALL    LOADBC
   814F 0A            [ 7]  146         LD      A,(BC)
   8150 18 25         [12]  147         JR      SRESP
   8152                     148 MWRITE:
   8152 CD 5D 81      [17]  149         CALL    LOADBC
   8155 DD 7E 03      [19]  150         LD      A,(IX+3)
   8158 02            [ 7]  151         LD      (BC),A
   8159 3E 57         [ 7]  152         LD      A,0x57  ;'W'
   815B 18 1A         [12]  153         JR      SRESP
   815D                     154 LOADBC:
   815D DD 7E 01      [19]  155         LD      A,(IX+1)
   8160 47            [ 4]  156         LD      B,A
   8161 DD 7E 02      [19]  157         LD      A,(IX+2)
   8164 4F            [ 4]  158         LD      C,A
   8165 C9            [10]  159         RET
   8166                     160 PREAD:
   8166 CD 5D 81      [17]  161         CALL    LOADBC
   8169 ED 78         [12]  162         IN      A,(C)
   816B 18 0A         [12]  163         JR      SRESP
   816D                     164 PWRITE:
   816D CD 5D 81      [17]  165         CALL    LOADBC
   8170 DD 7E 03      [19]  166         LD      A,(IX+3)
   8173 ED 79         [12]  167         OUT     (C),A
   8175 3E 4F         [ 7]  168         LD      A,0x4F  ;'O'
   8177                     169 SRESP:
   8177 CD 16 81      [17]  170         CALL    I2CSRESP
   817A                     171 RHERE:
   817A 37            [ 4]  172         SCF
   817B C9            [10]  173         RET
   817C                     174 REMCALL:
   817C 21 46 80      [10]  175         LD      HL,START
   817F E5            [11]  176         PUSH    HL
   8180 CD 43 81      [17]  177         CALL    LOADHL
   8183 E9            [ 4]  178         JP      (HL)
                            179     
   8184                     180 INIT:
   8184 31 F0 77      [10]  181         LD      SP,RAMADDR   ; have to set valid SP
   8187 DD 21 F0 77   [14]  182         LD      IX,RAMADDR   ; Easy to index command buffer
                            183         
                            184 ; Main routine
   818B                     185 MAIN:
   818B CD 27 81      [17]  186         CALL    POLL
   818E 38 FB         [12]  187         JR      C,MAIN
                            188         
   8190 01 80 01      [10]  189         LD      BC,BIGDEL
   8193                     190 MLOOP:
   8193 0B            [ 6]  191         DEC     BC
   8194 79            [ 4]  192         LD      A,C
   8195 B0            [ 4]  193         OR      B
   8196 20 FB         [12]  194         JR      NZ,MLOOP
   8198 18 F1         [12]  195         JR      MAIN
                            196 
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
   87C0 00 01 02 03 04 05    24         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   87D0 10 11 12 13 14 15    25         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
                             26 
                             15 
