                              1 ;
                              2 ; Moniker - 6502 Version
                              3 ; by Frank Palazzolo
                              4 ; For ROM IO Hardware
                              5 ;
                              6         .area   CODE1   (ABS)   ; ASXXXX directive, absolute addressing
                              7 
                              8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              9 ; You may need to adjust these variables for different targets
                             10 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             11 
                             12 ; RAM SETTINGS - usually in zero page
                             13 
                     0000    14 RAMSTRT .equ    0x00    ;start of ram, needs 7 bytes starting here
                     00FF    15 SSTACK	.equ	0xff	;start of stack, needs some memory below this address
                             16 
                             17 ; ROM SETTINGS - usually the last 2K of memory for 6502
                             18 
                     F800    19 SCHIP   .equ     0xf800   ;start of chip memory mapping
                             20 
                     FC00    21 IOREGR	.equ	SCHIP+0x0400	;reserved region for IO Read
                     FD00    22 IOREGW	.equ	SCHIP+0x0500	;reserved region for IO Write
                     FFFA    23 VECTORS	.equ	SCHIP+0x07fa	;reserved for vectors
                             24 
                             25 ; TIMER SETTING
                     0180    26 BIGDEL	.equ	0x0180   ;delay factor
                             27 
                     0011    28 I2CRADR .equ     0x11    ;I2C read address  - I2C address 0x08
                     0010    29 I2CWADR .equ     0x10    ;I2C write address - I2C address 0x08
                             30 
                             31 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             32 ; RAM Variables	
                             33 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             34 
                     0000    35 OUTBUF	.equ	RAMSTRT	        ;buffer for output states
                     0001    36 B	.equ	RAMSTRT+0x01	;general purpose
                     0002    37 C	.equ	RAMSTRT+0x02	;general purpose
                     0003    38 CMDBUF0 .equ	RAMSTRT+0x03	;command buffer
                     0004    39 CMDBUF1 .equ	RAMSTRT+0x04	;command buffer
                     0005    40 CMDBUF2 .equ	RAMSTRT+0x05	;command buffer
                     0006    41 CMDBUF3 .equ	RAMSTRT+0x06	;command buffer
                             42 
                             43 ;	.org	SCHIP	;last 2K of memory starts here
                             44 
                             45 ;        .ds     0x0500,0xff       ; fill front and io read region with $FF
                             46 
   FD00                      47         .org    IOREGW
                             48         
   FD00 00 01 02 03 04 05    49         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   FD10 10 11 12 13 14 15    50         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
   FD20 20 21 22 23 24 25    51         .DB     0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f
        26 27 28 29 2A 2B
        2C 2D 2E 2F
   FD30 30 31 32 33 34 35    52         .DB     0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,0x3e,0x3f
        36 37 38 39 3A 3B
        3C 3D 3E 3F
   FD40 40 41 42 43 44 45    53         .DB     0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f
        46 47 48 49 4A 4B
        4C 4D 4E 4F
   FD50 50 51 52 53 54 55    54         .DB     0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0x5b,0x5c,0x5d,0x5e,0x5f
        56 57 58 59 5A 5B
        5C 5D 5E 5F
   FD60 60 61 62 63 64 65    55         .DB     0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f
        66 67 68 69 6A 6B
        6C 6D 6E 6F
   FD70 70 71 72 73 74 75    56         .DB     0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,0x7b,0x7c,0x7d,0x7e,0x7f
        76 77 78 79 7A 7B
        7C 7D 7E 7F
   FD80 80 81 82 83 84 85    57         .DB     0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f
        86 87 88 89 8A 8B
        8C 8D 8E 8F
   FD90 90 91 92 93 94 95    58         .DB     0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9a,0x9b,0x9c,0x9d,0x9e,0x9f
        96 97 98 99 9A 9B
        9C 9D 9E 9F
   FDA0 A0 A1 A2 A3 A4 A5    59         .DB     0xa0,0xa1,0xa2,0xa3,0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xaa,0xab,0xac,0xad,0xae,0xaf
        A6 A7 A8 A9 AA AB
        AC AD AE AF
   FDB0 B0 B1 B2 B3 B4 B5    60         .DB     0xb0,0xb1,0xb2,0xb3,0xb4,0xb5,0xb6,0xb7,0xb8,0xb9,0xba,0xbb,0xbc,0xbd,0xbe,0xbf
        B6 B7 B8 B9 BA BB
        BC BD BE BF
   FDC0 C0 C1 C2 C3 C4 C5    61         .DB     0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xc8,0xc9,0xca,0xcb,0xcc,0xcd,0xce,0xcf
        C6 C7 C8 C9 CA CB
        CC CD CE CF
   FDD0 D0 D1 D2 D3 D4 D5    62         .DB     0xd0,0xd1,0xd2,0xd3,0xd4,0xd5,0xd6,0xd7,0xd8,0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xdf
        D6 D7 D8 D9 DA DB
        DC DD DE DF
   FDE0 E0 E1 E2 E3 E4 E5    63         .DB     0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe6,0xe7,0xe8,0xe9,0xea,0xeb,0xec,0xed,0xee,0xef
        E6 E7 E8 E9 EA EB
        EC ED EE EF
   FDF0 F0 F1 F2 F3 F4 F5    64         .DB     0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc,0xfd,0xfe,0xff
        F6 F7 F8 F9 FA FB
        FC FD FE FF
                             65 
                             66         ; Code fits into the last 512 bytes of memory
   FE00                      67         .org     SCHIP+0x0600     ;code starts here
                             68 
                             69 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             70 ; This function is called once, and should be used do any game-specific
                             71 ; initialization that is required
                             72 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             73 
   FE00                      74 ONCE:
                             75 ;       YOUR CODE CAN GO HERE
   FE00 60            [ 6]   76         rts
                             77 
                             78 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             79 ; This function is called every time during the polling loop.  It can be
                             80 ; used to run watchdog code, etc.  I have provided a simple delay loop
                             81 ; so that the I2C slave is not overwhelmed
                             82 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             83 
   FE01                      84 EVERY:
                             85 ;       YOUR CODE CAN GO HERE
   FE01 60            [ 6]   86         rts
                             87 
                             88 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             89 ; Main Program code starts here
                             90 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             91 
                             92 ; NMI Handler
   FE02 40            [ 6]   93 NMI:	rti             ;Don't do anything on an NMI
                             94 
   FE03 A5 00         [ 3]   95 SETSCL:	lda	OUTBUF
   FE05 09 01         [ 2]   96 	ora	#0x01
   FE07 85 00         [ 3]   97         sta     OUTBUF
   FE09 AA            [ 2]   98         tax
   FE0A BD 00 FD      [ 5]   99         lda     IOREGW,X
   FE0D 20 3F FE      [ 6]  100 	jsr	I2CDLY
   FE10 60            [ 6]  101 	rts
                            102 
   FE11 A5 00         [ 3]  103 CLRSCL:	lda	OUTBUF
   FE13 29 FE         [ 2]  104 	and	#0xfe
   FE15 85 00         [ 3]  105 	sta	OUTBUF
   FE17 AA            [ 2]  106         tax
   FE18 BD 00 FD      [ 5]  107         lda     IOREGW,X
   FE1B 60            [ 6]  108 	rts
                            109 
   FE1C A5 00         [ 3]  110 SETSDA:	lda	OUTBUF
   FE1E 29 FD         [ 2]  111 	and	#0xfd
   FE20 85 00         [ 3]  112         sta     OUTBUF
   FE22 AA            [ 2]  113         tax
   FE23 BD 00 FD      [ 5]  114         lda     IOREGW,X
   FE26 20 3F FE      [ 6]  115 	jsr	I2CDLY
   FE29 60            [ 6]  116 	rts
                            117 
   FE2A A5 00         [ 3]  118 CLRSDA:	lda	OUTBUF
   FE2C 09 02         [ 2]  119 	ora	#0x02
   FE2E 85 00         [ 3]  120         sta     OUTBUF
   FE30 AA            [ 2]  121         tax
   FE31 BD 00 FD      [ 5]  122         lda     IOREGW,X
   FE34 20 3F FE      [ 6]  123 	jsr	I2CDLY
   FE37 60            [ 6]  124 	rts
                            125 
   FE38 A6 00         [ 3]  126 READSDA:	ldx	OUTBUF
   FE3A BD 00 FC      [ 5]  127         lda     IOREGR,X
   FE3D 6A            [ 2]  128         ror
   FE3E 60            [ 6]  129 	rts				
                            130 
                            131 ; Delay for half a bit time
   FE3F 60            [ 6]  132 I2CDLY:	rts		; TBD - this is plenty?
                            133 
                            134 ; I2C Start Condition
   FE40                     135 I2CSTART:
   FE40 20 2A FE      [ 6]  136         jsr    CLRSDA      
   FE43 20 11 FE      [ 6]  137         jsr    CLRSCL
   FE46 60            [ 6]  138         rts
                            139 
                            140 ; I2C Stop Condition
                            141 ; Uses HL
                            142 ; Destroys A
   FE47                     143 I2CSTOP:
   FE47 20 2A FE      [ 6]  144         jsr    CLRSDA
   FE4A 20 03 FE      [ 6]  145         jsr    SETSCL
   FE4D 20 1C FE      [ 6]  146         jsr    SETSDA
   FE50 60            [ 6]  147         rts
                            148         
   FE51                     149 I2CRBIT:
   FE51 20 1C FE      [ 6]  150 	jsr	SETSDA
   FE54 20 03 FE      [ 6]  151 	jsr	SETSCL
   FE57 20 38 FE      [ 6]  152 	jsr	READSDA	; sets/clears carry flag
   FE5A 20 11 FE      [ 6]  153 	jsr     CLRSCL
   FE5D 60            [ 6]  154 	rts		; carry flag still good here
                            155 
   FE5E                     156 I2CWBIT:
   FE5E 90 06         [ 4]  157 	bcc	DOCLR
   FE60 20 1C FE      [ 6]  158 	jsr	SETSDA
   FE63 4C 69 FE      [ 3]  159 	jmp	AHEAD
   FE66                     160 DOCLR:
   FE66 20 2A FE      [ 6]  161 	jsr	CLRSDA
   FE69                     162 AHEAD:
   FE69 20 03 FE      [ 6]  163 	jsr	SETSCL
   FE6C 20 11 FE      [ 6]  164 	jsr	CLRSCL
   FE6F 60            [ 6]  165 	rts
                            166         
   FE70                     167 I2CWBYTE:
   FE70 48            [ 3]  168 	pha
   FE71 A9 08         [ 2]  169 	lda	#0x08
   FE73 85 01         [ 3]  170 	sta	B
   FE75 68            [ 4]  171 	pla
   FE76                     172 ILOOP:
   FE76 2A            [ 2]  173 	rol
   FE77 48            [ 3]  174 	pha
   FE78 20 5E FE      [ 6]  175 	jsr	I2CWBIT
   FE7B 68            [ 4]  176 	pla
   FE7C C6 01         [ 5]  177 	dec	B
   FE7E D0 F6         [ 4]  178 	bne	ILOOP
   FE80 20 51 FE      [ 6]  179 	jsr	I2CRBIT
   FE83 60            [ 6]  180 	rts
                            181 	
   FE84                     182 I2CRBYTE:
   FE84 A9 08         [ 2]  183         lda	#0x08
   FE86 85 01         [ 3]  184 	sta	B
   FE88 A9 00         [ 2]  185 	lda	#0x00
   FE8A 85 02         [ 3]  186 	sta	C
   FE8C                     187 LOOP3:
   FE8C 20 51 FE      [ 6]  188         jsr     I2CRBIT     ; get bit in carry flag
   FE8F 26 02         [ 5]  189         rol     C           ; rotate carry into bit0 of C register
   FE91 C6 01         [ 5]  190         dec	B
   FE93 D0 F7         [ 4]  191         bne    	LOOP3
   FE95 18            [ 2]  192         clc           	    ; clear carry flag              
   FE96 20 5E FE      [ 6]  193         jsr   	I2CWBIT
   FE99 A5 02         [ 3]  194         lda  	C
   FE9B 60            [ 6]  195         rts
                            196 
   FE9C                     197 I2CRREQ:
   FE9C 20 40 FE      [ 6]  198         jsr     I2CSTART
   FE9F A9 11         [ 2]  199         lda	#I2CRADR
   FEA1 20 70 FE      [ 6]  200         jsr     I2CWBYTE
   FEA4 B0 17         [ 4]  201         bcs     SKIP
   FEA6 20 84 FE      [ 6]  202         jsr     I2CRBYTE
   FEA9 85 03         [ 3]  203         sta     CMDBUF0
   FEAB 20 84 FE      [ 6]  204         jsr     I2CRBYTE
   FEAE 85 04         [ 3]  205         sta     CMDBUF1
   FEB0 20 84 FE      [ 6]  206         jsr     I2CRBYTE
   FEB3 85 05         [ 3]  207         sta     CMDBUF2
   FEB5 20 84 FE      [ 6]  208         jsr     I2CRBYTE
   FEB8 85 06         [ 3]  209         sta     CMDBUF3
   FEBA 4C D1 FE      [ 3]  210         jmp     ENDI2C
                            211     
   FEBD                     212 SKIP:                       ; If no device present, fake an idle response
   FEBD A9 2E         [ 2]  213         lda     #0x2e  ; '.'
   FEBF 85 03         [ 3]  214         sta     CMDBUF0
   FEC1 4C D1 FE      [ 3]  215         jmp     ENDI2C
                            216 
   FEC4                     217 I2CSRESP:
   FEC4 48            [ 3]  218         pha
   FEC5 20 40 FE      [ 6]  219         jsr     I2CSTART
   FEC8 A9 10         [ 2]  220         lda     #I2CWADR
   FECA 20 70 FE      [ 6]  221         jsr     I2CWBYTE
   FECD 68            [ 4]  222         pla
   FECE 20 70 FE      [ 6]  223         jsr     I2CWBYTE
   FED1                     224 ENDI2C:
   FED1 20 47 FE      [ 6]  225         jsr     I2CSTOP
   FED4 60            [ 6]  226         rts
                            227 
   FED5                     228 POLL:
   FED5 20 9C FE      [ 6]  229         jsr     I2CRREQ
   FED8 A5 03         [ 3]  230         lda     CMDBUF0
   FEDA C9 52         [ 2]  231         cmp     #0x52    	; 'R' - Read memory
   FEDC F0 0A         [ 4]  232         beq     MREAD
   FEDE C9 57         [ 2]  233         cmp     #0x57    	; 'W' - Write memory
   FEE0 F0 10         [ 4]  234         beq	MWRITE
   FEE2 C9 43         [ 2]  235         cmp     #0x43    	; 'C' - Call subroutine
   FEE4 F0 26         [ 4]  236         beq	REMCALL
   FEE6 18            [ 2]  237         clc
   FEE7 60            [ 6]  238         rts
                            239 
   FEE8                     240 MREAD:
   FEE8 20 FE FE      [ 6]  241         jsr     LOADBC
   FEEB A0 00         [ 2]  242         ldy	#0x00
   FEED B1 01         [ 6]  243         lda	[B],Y
   FEEF 4C 07 FF      [ 3]  244         jmp     SRESP
   FEF2                     245 MWRITE:
   FEF2 20 FE FE      [ 6]  246         jsr     LOADBC
   FEF5 A5 06         [ 3]  247         lda     CMDBUF3
   FEF7 91 01         [ 6]  248         sta     [B],Y
   FEF9 A9 57         [ 2]  249         lda     #0x57  	;'W'
   FEFB 4C 07 FF      [ 3]  250         jmp     SRESP
   FEFE                     251 LOADBC:
   FEFE A5 05         [ 3]  252 	lda	CMDBUF2
   FF00 85 01         [ 3]  253 	sta	B
   FF02 A5 04         [ 3]  254 	lda	CMDBUF1
   FF04 85 02         [ 3]  255 	sta	C
   FF06 60            [ 6]  256 	rts
                            257 	
   FF07                     258 SRESP:
   FF07 20 C4 FE      [ 6]  259         jsr    I2CSRESP
   FF0A                     260 RHERE:
   FF0A 38            [ 2]  261         sec
   FF0B 60            [ 6]  262         rts
   FF0C                     263 REMCALL:
   FF0C A9 FF         [ 2]  264 	lda	#>(START-1)
   FF0E 48            [ 3]  265         pha
   FF0F A9 17         [ 2]  266         lda	#<(START-1)
   FF11 48            [ 3]  267         pha
   FF12 20 FE FE      [ 6]  268         jsr     LOADBC
   FF15 6C 01 00      [ 5]  269         jmp     [B]
                            270         
                            271 ;;;;;;;;;;
                            272 	
   FF18                     273 START:
   FF18 78            [ 2]  274         sei             ; disable interrupts
   FF19 A2 FF         [ 2]  275 	ldx	#SSTACK
   FF1B 9A            [ 2]  276 	txs		; Init stack
   FF1C D8            [ 2]  277 	cld		; No Decimal
   FF1D 20 00 FE      [ 6]  278         jsr     ONCE
                            279 
                            280 ; Main routine
   FF20                     281 MAIN:
   FF20 20 01 FE      [ 6]  282         jsr     EVERY
   FF23 20 D5 FE      [ 6]  283         jsr     POLL
   FF26 B0 F8         [ 4]  284         bcs     MAIN
   FF28 A9 01         [ 2]  285         lda	#BIGDEL>>8
   FF2A 85 01         [ 3]  286         sta	B
   FF2C A9 80         [ 2]  287         lda	#BIGDEL%256
   FF2E 85 02         [ 3]  288         sta	C
   FF30                     289 MLOOP:
   FF30 A5 02         [ 3]  290         lda	C
   FF32 F0 05         [ 4]  291         beq	DECBOTH
   FF34 C6 02         [ 5]  292         dec	C
   FF36 4C 30 FF      [ 3]  293         jmp	MLOOP
   FF39                     294 DECBOTH:
   FF39 A5 01         [ 3]  295 	lda	B
   FF3B F0 E3         [ 4]  296 	beq	MAIN
   FF3D C6 02         [ 5]  297 	dec	C
   FF3F C6 01         [ 5]  298 	dec	B
   FF41 4C 30 FF      [ 3]  299 	jmp	MLOOP
                            300 
                            301 ;       vectors
                            302 
   FFFA                     303 	.org	SCHIP+0x07fa
                            304 
   FFFA 02 FE               305 	.dw	NMI
   FFFC 18 FF               306 	.dw	START
   FFFE 18 FF               307 	.dw	START
                            308 	
                            309 	
                            310 	
