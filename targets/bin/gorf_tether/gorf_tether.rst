                              1 ;****************************************************************
                              2 ; This file is auto-generated by ddmake from gorf_tether.toml
                              3 ; *** DO NOT EDIT ***
                              4 ;****************************************************************
                              5 
                              6 ; Start of chip memory mapping
                     0000     7 STRTADD = 0x0000
                              8 
                              9 ; 2K ROM
                     0800    10 ROMSIZE = 0x0800
                             11 
                             12 ; The code actually needs 4 bytes ram at this address for the command buffer.
                             13 ; However, stack also starts here, and will grow down (towards 0) from this point.
                             14 ; So, we need some above and below this address.  I generally choose the
                             15 ; Top of RAM minus 16
                     DFF0    16 RAMADDR = 0xdff0
                             17 
                             18 ; delay factor
                     0180    19 BIGDEL = 0x0180
                             20 
                             21         .include "../core/dd.def"
                              1 
                     0800     2 ROMEND  .equ    STRTADD+ROMSIZE
                              3 
                              4 
                             22         .include "../core/z80.def"
                              1 ; Same for all Z80s
                     0038     2 IRQADD  .equ    0x0038      ; location of IRQ handler
                     0066     3 NMIADD  .equ    0x0066      ; location of NMI handler
                             23 
                             24 ;------- region1  -----------------------------------------------
                             25 
                             26         .bank   region1 (base=STRTADD, size=IRQADD-STRTADD)
                             27         .area   region1 (ABS, BANK=region1)
                             28 
                             29 ;
                             30 ;       START CODE
                             31 ;
   0000                      32 START:
   0000 F3            [ 4]   33         DI                  ; Disable interrupts - we don't handle them
   0001 31 F0 DF      [10]   34         LD      SP,RAMADDR  ; have to set valid SP
                             35 ;       YOUR SMALL CODE CAN GO HERE
   0004 C3 69 00      [10]   36         JP      START2
                             37 
                             38 
                             39 ;------- region2  -----------------------------------------------
                             40 
                             41         .bank   region2 (base=IRQADD, size=NMIADD-IRQADD)
                             42         .area   region2 (ABS, BANK=region2)
                             43 
                             44 ;
                             45 ;       IRQ HANDLER
                             46 ;
   0038                      47 IRQ:
   0038 ED 4D         [14]   48         RETI
                             49 
                             50 
                             51 ;------- region3  -----------------------------------------------
                             52 
                             53         .bank   region3 (base=NMIADD, size=ROMEND-NMIADD)
                             54         .area   region3 (ABS, BANK=region3)
                             55 
   0066 C3 00 00      [10]   56 NMI:    JP      START       ; restart on test button press
                             57 
                             58 ;
                             59 ;       START CODE 2
                             60 ;
   0069                      61 START2:
                             62 ;       YOUR CODE CAN GO HERE
   0069 C3 6C 00      [10]   63         JP      INIT
                             64 
                             65         .include "../core/z80_main.asm"
                              1 ; I2C ADDRESSING
                     0011     2 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010     3 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                              4 
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 ; RAM Variables	
                              7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              8 
                     DFF0     9 CMDBUF  .equ    RAMADDR     ; Need only 4 bytes of ram for command buffer
                             10 
   006C                      11 INIT:
   006C DD 21 F0 DF   [14]   12         LD      IX,CMDBUF   ; Easy to index command buffer
   0070 16 00         [ 7]   13         LD      D,#0x00     ; initialize D to prevent index overflow
                             14 
                             15 ; Main routine
   0072                      16 MAIN:
   0072 CD 78 01      [17]   17         CALL    EVERY
   0075 CD 1B 01      [17]   18         CALL    POLL
   0078 DA 72 00      [10]   19         JP      C,MAIN
                             20         
   007B 01 80 01      [10]   21         LD      BC,BIGDEL
   007E                      22 DLOOP:
   007E 0B            [ 6]   23         DEC     BC
   007F 79            [ 4]   24         LD      A,C
   0080 B0            [ 4]   25         OR      B
   0081 C2 7E 00      [10]   26         JP      NZ,DLOOP
   0084 C3 72 00      [10]   27         JP      MAIN
                             28 
                             29 ; Delay for half a bit time
   0087                      30 I2CDELAY:
   0087 C9            [10]   31         RET     ; This is plenty
                             32 
                             33 ; I2C Start Condition
                             34 ; Uses HL
                             35 ; Destroys A
   0088                      36 I2CSTART:
   0088 CD 96 01      [17]   37         CALL    CLRSDA      
   008B CD 85 01      [17]   38         CALL    CLRSCL
   008E C9            [10]   39         RET
                             40 
                             41 ; I2C Stop Condition
                             42 ; Uses HL
                             43 ; Destroys A
   008F                      44 I2CSTOP:
   008F CD 96 01      [17]   45         CALL    CLRSDA
   0092 CD 7B 01      [17]   46         CALL    SETSCL
   0095 CD 8C 01      [17]   47         CALL    SETSDA
   0098 C9            [10]   48         RET
                             49 
                             50 ; I2C Read Bit routine
                             51 ; Returns bit in carry blag
                             52 ; Destroys A
   0099                      53 I2CRBIT:
   0099 CD 8C 01      [17]   54         CALL    SETSDA
   009C CD 7B 01      [17]   55         CALL    SETSCL
   009F CD A0 01      [17]   56         CALL    READSDA
   00A2 F5            [11]   57         PUSH    AF          ; save carry flag
   00A3 CD 85 01      [17]   58         CALL    CLRSCL
   00A6 F1            [10]   59         POP     AF          ; rv in carry flag
   00A7 C9            [10]   60         RET
                             61 
                             62 ; I2C Write Bit routine
                             63 ; Takes carry flag
                             64 ; Destroys A
   00A8                      65 I2CWBIT:
   00A8 30 05         [12]   66         JR      NC,DOCLR
   00AA CD 8C 01      [17]   67         CALL    SETSDA
   00AD 18 03         [12]   68         JR      AHEAD
   00AF                      69 DOCLR:
   00AF CD 96 01      [17]   70         CALL    CLRSDA
   00B2                      71 AHEAD:
   00B2 CD 7B 01      [17]   72         CALL    SETSCL
   00B5 CD 85 01      [17]   73         CALL    CLRSCL
   00B8 C9            [10]   74         RET
                             75 
                             76 ; I2C Write Byte routine
                             77 ; Takes A
                             78 ; Destroys B
                             79 ; Returns carry bit
   00B9                      80 I2CWBYTE:
   00B9 06 08         [ 7]   81         LD      B,8
   00BB                      82 ILOOP:
   00BB C5            [11]   83         PUSH    BC          ; save B
   00BC CB 07         [ 8]   84         RLC     A    
   00BE F5            [11]   85         PUSH    AF          ; save A
   00BF CD A8 00      [17]   86         CALL    I2CWBIT
   00C2 F1            [10]   87         POP     AF
   00C3 C1            [10]   88         POP     BC
   00C4 10 F5         [13]   89         DJNZ    ILOOP
   00C6 CD 99 00      [17]   90         CALL    I2CRBIT
   00C9 C9            [10]   91         RET
                             92 
                             93 ; I2C Read Byte routine
                             94 ; Destroys BC
                             95 ; Returns A
   00CA                      96 I2CRBYTE:
   00CA 06 08         [ 7]   97         LD      B,8
   00CC 0E 00         [ 7]   98         LD      C,0
   00CE                      99 LOOP3:
   00CE C5            [11]  100         PUSH    BC
   00CF CD 99 00      [17]  101         CALL    I2CRBIT     ; get bit in carry flag
   00D2 C1            [10]  102         POP     BC
   00D3 CB 11         [ 8]  103         RL      C           ; rotate carry into bit0 of C register
   00D5 10 F7         [13]  104         DJNZ    LOOP3
   00D7 AF            [ 4]  105         XOR     A           ; clear carry flag              
   00D8 C5            [11]  106         PUSH    BC
   00D9 CD A8 00      [17]  107         CALL    I2CWBIT
   00DC C1            [10]  108         POP     BC
   00DD 79            [ 4]  109         LD      A,C
   00DE C9            [10]  110         RET
                            111 ;
                            112 
                            113 ; Read 4-byte I2C Command from device into CMDBUF
                            114 ; Uses HL
                            115 ; Destroys A,BC,HL
   00DF                     116 I2CRREQ:
   00DF CD 88 00      [17]  117         CALL    I2CSTART
   00E2 3E 11         [ 7]  118         LD      A,I2CRADR
   00E4 CD B9 00      [17]  119         CALL    I2CWBYTE
   00E7 38 1A         [12]  120         JR      C,SKIP
   00E9 CD CA 00      [17]  121         CALL    I2CRBYTE
   00EC DD 77 00      [19]  122         LD      (IX),A
   00EF CD CA 00      [17]  123         CALL    I2CRBYTE
   00F2 DD 77 01      [19]  124         LD      (IX+1),A  
   00F5 CD CA 00      [17]  125         CALL    I2CRBYTE
   00F8 DD 77 02      [19]  126         LD      (IX+2),A
   00FB CD CA 00      [17]  127         CALL    I2CRBYTE
   00FE DD 77 03      [19]  128         LD      (IX+3),A
   0101 18 14         [12]  129         JR      ENDI2C
                            130     
   0103                     131 SKIP:                       ; If no device present, fake an idle response
   0103 3E 2E         [ 7]  132         LD      A,0x2e  ; '.'
   0105 DD 77 00      [19]  133         LD      (IX),A
   0108 18 0D         [12]  134         JR      ENDI2C
                            135 
   010A                     136 I2CSRESP:
   010A F5            [11]  137         PUSH    AF
   010B CD 88 00      [17]  138         CALL    I2CSTART
   010E 3E 10         [ 7]  139         LD      A,I2CWADR
   0110 CD B9 00      [17]  140         CALL    I2CWBYTE
   0113 F1            [10]  141         POP     AF
   0114 CD B9 00      [17]  142         CALL    I2CWBYTE
   0117                     143 ENDI2C:
   0117 CD 8F 00      [17]  144         CALL    I2CSTOP
   011A C9            [10]  145         RET
                            146 ;
                            147 
                            148 ; Main Polling loop
                            149 ; Return carry flag if we got a valid command (not idle)
   011B                     150 POLL:
   011B CD DF 00      [17]  151         CALL    I2CRREQ
   011E DD 7E 00      [19]  152         LD      A,(IX)
   0121 FE 52         [ 7]  153         CP      0x52    ; 'R' - Read memory
   0123 28 1B         [12]  154         JR      Z,MREAD
   0125 FE 57         [ 7]  155         CP      0x57    ; 'W' - Write memory
   0127 28 1D         [12]  156         JR      Z,MWRITE
   0129 FE 49         [ 7]  157         CP      0x49    ; 'I' - Input from port
   012B 28 2D         [12]  158         JR      Z,PREAD
   012D FE 4F         [ 7]  159         CP      0x4F    ; 'O' - Output from port
   012F 28 30         [12]  160         JR      Z,PWRITE
   0131 FE 43         [ 7]  161         CP      0x43    ; 'C' - Call subroutine
   0133 28 3B         [12]  162         JR      Z,REMCALL
   0135 3F            [ 4]  163         CCF
   0136 C9            [10]  164         RET
   0137                     165 LOADHL:
   0137 DD 7E 01      [19]  166         LD      A,(IX+1)
   013A 67            [ 4]  167         LD      H,A
   013B DD 7E 02      [19]  168         LD      A,(IX+2)
   013E 6F            [ 4]  169         LD      L,A
   013F C9            [10]  170         RET    
   0140                     171 MREAD:
   0140 CD 51 01      [17]  172         CALL    LOADBC
   0143 0A            [ 7]  173         LD      A,(BC)
   0144 18 25         [12]  174         JR      SRESP
   0146                     175 MWRITE:
   0146 CD 51 01      [17]  176         CALL    LOADBC
   0149 DD 7E 03      [19]  177         LD      A,(IX+3)
   014C 02            [ 7]  178         LD      (BC),A
   014D 3E 57         [ 7]  179         LD      A,0x57  ;'W'
   014F 18 1A         [12]  180         JR      SRESP
   0151                     181 LOADBC:
   0151 DD 7E 01      [19]  182         LD      A,(IX+1)
   0154 47            [ 4]  183         LD      B,A
   0155 DD 7E 02      [19]  184         LD      A,(IX+2)
   0158 4F            [ 4]  185         LD      C,A
   0159 C9            [10]  186         RET
   015A                     187 PREAD:
   015A CD 51 01      [17]  188         CALL    LOADBC
   015D ED 78         [12]  189         IN      A,(C)
   015F 18 0A         [12]  190         JR      SRESP
   0161                     191 PWRITE:
   0161 CD 51 01      [17]  192         CALL    LOADBC
   0164 DD 7E 03      [19]  193         LD      A,(IX+3)
   0167 ED 79         [12]  194         OUT     (C),A
   0169 3E 4F         [ 7]  195         LD      A,0x4F  ;'O'
   016B                     196 SRESP:
   016B CD 0A 01      [17]  197         CALL    I2CSRESP
   016E                     198 RHERE:
   016E 37            [ 4]  199         SCF
   016F C9            [10]  200         RET
   0170                     201 REMCALL:
   0170 21 00 00      [10]  202         LD      HL,START
   0173 E5            [11]  203         PUSH    HL
   0174 CD 37 01      [17]  204         CALL    LOADHL
   0177 E9            [ 4]  205         JP      (HL)
                            206 
                             66 ;
                             67 ;       EVERY CODE
                             68 ;
   0178                      69 EVERY:
   0178 DB 10         [11]   70         IN	A,(0x10)    ; hit watchdog
   017A C9            [10]   71         RET
                             72 
                             73         .include "../io/gorf-tether.asm"
                              1 ; SCL  - IN  0x16, bit0 lamp0 (selected by A11,A10,A9, Data is A8)
                              2 ; DOUT - IN  0x16, bit1 lamp1 (selected by A11,A10,A9, Data is A8)
                              3 ; DIN  - IN  0x13, bit0, (0x01) DIP, SW1
                              4 ;
                              5 
                     0013     6 DSPORT  .equ    0x13        ; dip switch 1 port
                     0016     7 CCPORT  .equ    0x16        ; port for lamps
                              8 
                              9 ; Set the SCL pin high
                             10 ; Destroys A, B and C
   017B                      11 SETSCL:
   017B 06 01         [ 7]   12         LD      B,0x01
   017D 0E 16         [ 7]   13         LD	    C,CCPORT
   017F ED 78         [12]   14         IN      A,(C)
   0181 CD 87 00      [17]   15         CALL    I2CDELAY
   0184 C9            [10]   16         RET
                             17     
                             18 ; Set the SCL pin low
                             19 ; Destroys A, B and C
   0185                      20 CLRSCL:
   0185 06 00         [ 7]   21         LD      B,0x00
   0187 0E 16         [ 7]   22         LD	    C,CCPORT
   0189 ED 78         [12]   23         IN      A,(C)
   018B C9            [10]   24         RET
                             25 
                             26 ; Set the DOUT pin low
                             27 ; Destroys A, B and C
   018C                      28 SETSDA:
   018C 06 02         [ 7]   29         LD      B,0x02
   018E 0E 16         [ 7]   30         LD	    C,CCPORT
   0190 ED 78         [12]   31         IN      A,(C)
   0192 CD 87 00      [17]   32         CALL    I2CDELAY
   0195 C9            [10]   33         RET
                             34 
                             35 ; Set the DOUT pin high
                             36 ; Destroys A, B and C 
   0196                      37 CLRSDA:
   0196 06 03         [ 7]   38         LD      B,0x03
   0198 0E 16         [ 7]   39         LD	    C,CCPORT
   019A ED 78         [12]   40         IN      A,(C)
   019C CD 87 00      [17]   41         CALL    I2CDELAY
   019F C9            [10]   42         RET
                             43 
                             44 ; Read the DIN pin 
                             45 ; returns bit in carry flag    
   01A0                      46 READSDA:
   01A0 DB 13         [11]   47         IN      A,(DSPORT)  ;0x01
   01A2 CB 3F         [ 8]   48         SRL     A           ;carry flag
   01A4 C9            [10]   49         RET
                             74 
