                              2 
                              3 ;--------------------------------------------------------------------------
                              4 ; TARGET-SPECIFIC DEFINITIONS
                              5 ;--------------------------------------------------------------------------
                              6 ; RAM SETTINGS - usually in zero page
                     0000     7 RAMSTRT .equ    0x00    ;start of ram, needs 7 bytes starting here
                     00FF     8 SSTACK	.equ	0xff	;start of stack, needs some memory below this address
                              9 
                             10 ;--------------------------------------------------------------------------
                             11 ; NMI HANDLER
                             12 ;--------------------------------------------------------------------------
                             13         .macro  NMI_MACRO
                             14         RTI
                             15         .endm
                             16 
                             17 ;--------------------------------------------------------------------------
                             18 ; STARTUP MACRO
                             19 ;
                             20 ; This are called once, and can be used do any target-specific
                             21 ; initialization that is required
                             22 ;--------------------------------------------------------------------------
                             23 
                             24         .macro  STARTUP_MACRO 
                             25         sei              ; Disable interrupts - we don't handle them
                             26         ldx     #SSTACK  ; hset up the stack
                             27         txs
                             28         cld              ; No Decimal
                             29 ;       YOUR CODE CAN GO HERE
                             30         .endm
                             31 
                             32 ;--------------------------------------------------------------------------
                             33 ; EVERY MACRO
                             34 ; This is called regularly, every polling loop, and can be used do any 
                             35 ; target-specific task that is required, such as hitting a watchdog
                             36 ;--------------------------------------------------------------------------
                             37 
                             38         .macro  EVERY_MACRO  
                             39         ; reset the starshp1 watchdog
                             40 	lda     #0x01
                             41 	sta     0xdc06
                             42 	lda     #0xfe
                             43 	sta     0xcc00
                             44 	sta     0xcc00
                             45 	sta     0xcc00
                             46 	sta     0xcc00
                             47 	sta     0xcc00
                             48 	sta     0xcc00
                             49 	sta     0xcc00
                             50 	sta     0xcc00
                             51 	sta     0xcc00
                             52 	sta     0xcc00
                             53 	sta     0xcc00
                             54 	sta     0xcc00
                             55 	sta     0xcc00
                             56 	sta     0xcc00
                             57 	sta     0xcc00
                             58 	sta     0xcc00
                             59 	sta     0xcc00
                             60 	sta     0xcc00
                             61 	sta     0xcc00
                             62 	sta     0xcc00
                             63 	sta     0xdc06
                             64 	rts
                             65         .endm        
                             66 
                             67 ;--------------------------------------------------------------------------
                             68 ; ROM TEMPLATE - this defines the rom layout, and which kind of io
                             69 ;--------------------------------------------------------------------------
                             70         .include "../rom_templates/6502_romio_f800_2k.asm"
                              1 
                              2 ; 2K ROM          
                     F800     3 STRTADD .equ    0xf800      ; start of chip memory mapping
                     0800     4 ROMSIZE .equ    0x0800
                              5 
                              6         .include "../dd/dd.def"
                              1 
                     0000     2 ROMEND  .equ    STRTADD+ROMSIZE
                              3 
                              4 
                              7         .include "../dd/6502.def"
                              1 ; Same for all 6502s
                     FFFA     2 VECTORS .equ    0xfffa      ; location of Vector table
                              8         .include "../io/romio.def"
                              1 ; For Demon Debugger Hardware - Rev D 
                              2 
                     FFA0     3 IOREGR   .equ   STRTADD+0x07a0    ;reserved region for IO READ
                     FFC0     4 IOREGW   .equ   STRTADD+0x07c0    ;reserved region for IO WRITE
                              5 
                     FFA0     6 IOADD    .equ   IOREGR            ;start of region
                     FFE0     7 IOEND    .equ   STRTADD+0x07e0    ;end of region
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
                              9 
                             10 ; TIMER SETTING
                     0180    11 BIGDEL  .equ    0x0180      ; delay factor
                             12 
                             13         .bank   first   (base=STRTADD, size=IOADD-STRTADD)
                             14         .area   first   (ABS, BANK=first)
   F800                      15 STARTUP:
                             16         STARTUP_MACRO
   F800 78            [ 2]    1         sei              ; Disable interrupts - we don't handle them
   F801 A2 FF         [ 2]    2         ldx     #SSTACK  ; hset up the stack
   F803 9A            [ 2]    3         txs
   F804 D8            [ 2]    4         cld              ; No Decimal
                              5 ;       YOUR CODE CAN GO HERE
                             17 
                             18         ; Entry to main routine here
                             19         .include "../dd/6502_main.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; RAM Variables	
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                     0000     5 OUTBUF	.equ	RAMSTRT	        ;buffer for output states
                     0001     6 B	.equ	RAMSTRT+0x01	;general purpose
                     0002     7 C	.equ	RAMSTRT+0x02	;general purpose
                     0003     8 CMDBUF0 .equ	RAMSTRT+0x03	;command buffer
                     0004     9 CMDBUF1 .equ	RAMSTRT+0x04	;command buffer
                     0005    10 CMDBUF2 .equ	RAMSTRT+0x05	;command buffer
                     0006    11 CMDBUF3 .equ	RAMSTRT+0x06	;command buffer
                             12 
                             13 ; I2C ADDRESSING
                     0011    14 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    15 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                             16 
   F805 A9 00         [ 2]   17         lda     #0x00
   F807 85 00         [ 3]   18         sta     OUTBUF
                             19 
                             20 ; Main routine
   F809                      21 MAIN:
   F809 20 06 F9      [ 6]   22         jsr     EVERY
   F80C 20 C3 F8      [ 6]   23         jsr     POLL
   F80F B0 F8         [ 4]   24         bcs     MAIN
   F811 A9 01         [ 2]   25         lda	#BIGDEL>>8
   F813 85 01         [ 3]   26         sta	B
   F815 A9 80         [ 2]   27         lda	#BIGDEL%256
   F817 85 02         [ 3]   28         sta	C
   F819                      29 MLOOP:
   F819 A5 02         [ 3]   30         lda	C
   F81B F0 05         [ 4]   31         beq	DECBOTH
   F81D C6 02         [ 5]   32         dec	C
   F81F 4C 19 F8      [ 3]   33         jmp	MLOOP
   F822                      34 DECBOTH:
   F822 A5 01         [ 3]   35 	lda	B
   F824 F0 E3         [ 4]   36 	beq	MAIN
   F826 C6 02         [ 5]   37 	dec	C
   F828 C6 01         [ 5]   38 	dec	B
   F82A 4C 19 F8      [ 3]   39 	jmp	MLOOP
                             40 
                             41 ; Delay for half a bit time
   F82D 60            [ 6]   42 I2CDLY:	rts		; TBD - this is plenty?
                             43 
                             44 ; I2C Start Condition
   F82E                      45 I2CSTART:
   F82E 20 74 F9      [ 6]   46         jsr    CLRSDA      
   F831 20 5B F9      [ 6]   47         jsr    CLRSCL
   F834 60            [ 6]   48         rts
                             49 
                             50 ; I2C Stop Condition
                             51 ; Uses HL
                             52 ; Destroys A
   F835                      53 I2CSTOP:
   F835 20 74 F9      [ 6]   54         jsr    CLRSDA
   F838 20 4D F9      [ 6]   55         jsr    SETSCL
   F83B 20 66 F9      [ 6]   56         jsr    SETSDA
   F83E 60            [ 6]   57         rts
                             58         
   F83F                      59 I2CRBIT:
   F83F 20 66 F9      [ 6]   60 	jsr	SETSDA
   F842 20 4D F9      [ 6]   61 	jsr	SETSCL
   F845 20 82 F9      [ 6]   62 	jsr	READSDA	; sets/clears carry flag
   F848 20 5B F9      [ 6]   63 	jsr     CLRSCL
   F84B 60            [ 6]   64 	rts		; carry flag still good here
                             65 
   F84C                      66 I2CWBIT:
   F84C 90 06         [ 4]   67 	bcc	DOCLR
   F84E 20 66 F9      [ 6]   68 	jsr	SETSDA
   F851 4C 57 F8      [ 3]   69 	jmp	AHEAD
   F854                      70 DOCLR:
   F854 20 74 F9      [ 6]   71 	jsr	CLRSDA
   F857                      72 AHEAD:
   F857 20 4D F9      [ 6]   73 	jsr	SETSCL
   F85A 20 5B F9      [ 6]   74 	jsr	CLRSCL
   F85D 60            [ 6]   75 	rts
                             76         
   F85E                      77 I2CWBYTE:
   F85E 48            [ 3]   78 	pha
   F85F A9 08         [ 2]   79 	lda	#0x08
   F861 85 01         [ 3]   80 	sta	B
   F863 68            [ 4]   81 	pla
   F864                      82 ILOOP:
   F864 2A            [ 2]   83 	rol
   F865 48            [ 3]   84 	pha
   F866 20 4C F8      [ 6]   85 	jsr	I2CWBIT
   F869 68            [ 4]   86 	pla
   F86A C6 01         [ 5]   87 	dec	B
   F86C D0 F6         [ 4]   88 	bne	ILOOP
   F86E 20 3F F8      [ 6]   89 	jsr	I2CRBIT
   F871 60            [ 6]   90 	rts
                             91 	
   F872                      92 I2CRBYTE:
   F872 A9 08         [ 2]   93         lda	#0x08
   F874 85 01         [ 3]   94 	sta	B
   F876 A9 00         [ 2]   95 	lda	#0x00
   F878 85 02         [ 3]   96 	sta	C
   F87A                      97 LOOP3:
   F87A 20 3F F8      [ 6]   98         jsr     I2CRBIT     ; get bit in carry flag
   F87D 26 02         [ 5]   99         rol     C           ; rotate carry into bit0 of C register
   F87F C6 01         [ 5]  100         dec	B
   F881 D0 F7         [ 4]  101         bne    	LOOP3
   F883 18            [ 2]  102         clc           	    ; clear carry flag              
   F884 20 4C F8      [ 6]  103         jsr   	I2CWBIT
   F887 A5 02         [ 3]  104         lda  	C
   F889 60            [ 6]  105         rts
                            106 
   F88A                     107 I2CRREQ:
   F88A 20 2E F8      [ 6]  108         jsr     I2CSTART
   F88D A9 11         [ 2]  109         lda	    #I2CRADR
   F88F 20 5E F8      [ 6]  110         jsr     I2CWBYTE
   F892 B0 17         [ 4]  111         bcs     SKIP
   F894 20 72 F8      [ 6]  112         jsr     I2CRBYTE
   F897 85 03         [ 3]  113         sta     CMDBUF0
   F899 20 72 F8      [ 6]  114         jsr     I2CRBYTE
   F89C 85 04         [ 3]  115         sta     CMDBUF1
   F89E 20 72 F8      [ 6]  116         jsr     I2CRBYTE
   F8A1 85 05         [ 3]  117         sta     CMDBUF2
   F8A3 20 72 F8      [ 6]  118         jsr     I2CRBYTE
   F8A6 85 06         [ 3]  119         sta     CMDBUF3
   F8A8 4C BF F8      [ 3]  120         jmp     ENDI2C
                            121     
   F8AB                     122 SKIP:                       ; If no device present, fake an idle response
   F8AB A9 2E         [ 2]  123         lda     #0x2e  ; '.'
   F8AD 85 03         [ 3]  124         sta     CMDBUF0
   F8AF 4C BF F8      [ 3]  125         jmp     ENDI2C
                            126 
   F8B2                     127 I2CSRESP:
   F8B2 48            [ 3]  128         pha
   F8B3 20 2E F8      [ 6]  129         jsr     I2CSTART
   F8B6 A9 10         [ 2]  130         lda     #I2CWADR
   F8B8 20 5E F8      [ 6]  131         jsr     I2CWBYTE
   F8BB 68            [ 4]  132         pla
   F8BC 20 5E F8      [ 6]  133         jsr     I2CWBYTE
   F8BF                     134 ENDI2C:
   F8BF 20 35 F8      [ 6]  135         jsr     I2CSTOP
   F8C2 60            [ 6]  136         rts
                            137 
   F8C3                     138 POLL:
   F8C3 20 8A F8      [ 6]  139         jsr     I2CRREQ
   F8C6 A5 03         [ 3]  140         lda     CMDBUF0
   F8C8 C9 52         [ 2]  141         cmp     #0x52    	; 'R' - Read memory
   F8CA F0 0A         [ 4]  142         beq     MREAD
   F8CC C9 57         [ 2]  143         cmp     #0x57    	; 'W' - Write memory
   F8CE F0 10         [ 4]  144         beq	MWRITE
   F8D0 C9 43         [ 2]  145         cmp     #0x43    	; 'C' - Call subroutine
   F8D2 F0 26         [ 4]  146         beq	REMCALL
   F8D4 18            [ 2]  147         clc
   F8D5 60            [ 6]  148         rts
                            149 
   F8D6                     150 MREAD:
   F8D6 20 EC F8      [ 6]  151         jsr     LOADBC
   F8D9 A0 00         [ 2]  152         ldy	#0x00
   F8DB B1 01         [ 6]  153         lda	[B],Y
   F8DD 4C F5 F8      [ 3]  154         jmp     SRESP
   F8E0                     155 MWRITE:
   F8E0 20 EC F8      [ 6]  156         jsr     LOADBC
   F8E3 A5 06         [ 3]  157         lda     CMDBUF3
   F8E5 91 01         [ 6]  158         sta     [B],Y
   F8E7 A9 57         [ 2]  159         lda     #0x57  	;'W'
   F8E9 4C F5 F8      [ 3]  160         jmp     SRESP
   F8EC                     161 LOADBC:
   F8EC A5 05         [ 3]  162 	lda	CMDBUF2
   F8EE 85 01         [ 3]  163 	sta	B
   F8F0 A5 04         [ 3]  164 	lda	CMDBUF1
   F8F2 85 02         [ 3]  165 	sta	C
   F8F4 60            [ 6]  166 	rts
                            167 	
   F8F5                     168 SRESP:
   F8F5 20 B2 F8      [ 6]  169         jsr    I2CSRESP
   F8F8                     170 RHERE:
   F8F8 38            [ 2]  171         sec
   F8F9 60            [ 6]  172         rts
   F8FA                     173 REMCALL:
   F8FA A9 F7         [ 2]  174 	    lda	#>(STARTUP-1)
   F8FC 48            [ 3]  175         pha
   F8FD A9 FF         [ 2]  176         lda	#<(STARTUP-1)
   F8FF 48            [ 3]  177         pha
   F900 20 EC F8      [ 6]  178         jsr     LOADBC
   F903 6C 01 00      [ 5]  179         jmp     [B]
                            180         
                            181 ;;;;;;;;;;
                            182 
                            183 
                             20 
   F906                      21 EVERY:
                             22         EVERY_MACRO
                              1         ; reset the starshp1 watchdog
   F906 A9 01         [ 2]    2 	lda     #0x01
   F908 8D 06 DC      [ 4]    3 	sta     0xdc06
   F90B A9 FE         [ 2]    4 	lda     #0xfe
   F90D 8D 00 CC      [ 4]    5 	sta     0xcc00
   F910 8D 00 CC      [ 4]    6 	sta     0xcc00
   F913 8D 00 CC      [ 4]    7 	sta     0xcc00
   F916 8D 00 CC      [ 4]    8 	sta     0xcc00
   F919 8D 00 CC      [ 4]    9 	sta     0xcc00
   F91C 8D 00 CC      [ 4]   10 	sta     0xcc00
   F91F 8D 00 CC      [ 4]   11 	sta     0xcc00
   F922 8D 00 CC      [ 4]   12 	sta     0xcc00
   F925 8D 00 CC      [ 4]   13 	sta     0xcc00
   F928 8D 00 CC      [ 4]   14 	sta     0xcc00
   F92B 8D 00 CC      [ 4]   15 	sta     0xcc00
   F92E 8D 00 CC      [ 4]   16 	sta     0xcc00
   F931 8D 00 CC      [ 4]   17 	sta     0xcc00
   F934 8D 00 CC      [ 4]   18 	sta     0xcc00
   F937 8D 00 CC      [ 4]   19 	sta     0xcc00
   F93A 8D 00 CC      [ 4]   20 	sta     0xcc00
   F93D 8D 00 CC      [ 4]   21 	sta     0xcc00
   F940 8D 00 CC      [ 4]   22 	sta     0xcc00
   F943 8D 00 CC      [ 4]   23 	sta     0xcc00
   F946 8D 00 CC      [ 4]   24 	sta     0xcc00
   F949 8D 06 DC      [ 4]   25 	sta     0xdc06
   F94C 60            [ 6]   26 	rts
                             23         
                             24         ; Routines for romio here
                             25         .include "../io/6502_romio.asm"
   F94D A5 00         [ 3]    1 SETSCL:	lda	OUTBUF
   F94F 09 01         [ 2]    2 	ora	#0x01
   F951 85 00         [ 3]    3         sta     OUTBUF
   F953 AA            [ 2]    4         tax
   F954 BD C0 FF      [ 5]    5         lda     IOREGW,X
   F957 20 2D F8      [ 6]    6 	jsr	I2CDLY
   F95A 60            [ 6]    7 	rts
                              8 
   F95B A5 00         [ 3]    9 CLRSCL:	lda	OUTBUF
   F95D 29 1E         [ 2]   10     and	#0x1e
   F95F 85 00         [ 3]   11     sta	OUTBUF
   F961 AA            [ 2]   12         tax
   F962 BD C0 FF      [ 5]   13         lda     IOREGW,X
   F965 60            [ 6]   14 	rts
                             15 
   F966 A5 00         [ 3]   16 SETSDA:	lda	OUTBUF
   F968 29 1D         [ 2]   17 	and	#0x1d
   F96A 85 00         [ 3]   18         sta     OUTBUF
   F96C AA            [ 2]   19         tax
   F96D BD C0 FF      [ 5]   20         lda     IOREGW,X
   F970 20 2D F8      [ 6]   21 	jsr	I2CDLY
   F973 60            [ 6]   22 	rts
                             23 
   F974 A5 00         [ 3]   24 CLRSDA:	lda	OUTBUF
   F976 09 02         [ 2]   25 	ora	#0x02
   F978 85 00         [ 3]   26         sta     OUTBUF
   F97A AA            [ 2]   27         tax
   F97B BD C0 FF      [ 5]   28         lda     IOREGW,X
   F97E 20 2D F8      [ 6]   29 	jsr	I2CDLY
   F981 60            [ 6]   30 	rts
                             31 
   F982 A6 00         [ 3]   32 READSDA:	ldx	OUTBUF
   F984 BD A0 FF      [ 5]   33         lda     IOREGR,X
   F987 6A            [ 2]   34         ror
   F988 60            [ 6]   35 	rts				
                             26 
   F989                      27 NMI:
                             28         NMI_MACRO
   F989 40            [ 6]    1         RTI
                             29 
                             30         ;--------------------------------------------------
                             31         ; The romio write region has a small table here
                             32         ;--------------------------------------------------
                             33         .bank   second  (base=IOREGW, size=IOEND-IOREGW)
                             34         .area   second  (ABS, BANK=second)
                             35         .include "../io/romio_table.asm"
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
   FFC0 00 01 02 03 04 05    24         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   FFD0 10 11 12 13 14 15    25         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
                             26 
                             36 
                             37         ;--------------------------------------------------
                             38         ; There is a little more room here, which is unused
                             39         ;--------------------------------------------------
                             40         .bank   third  (base=IOEND, size=VECTORS-IOEND)
                             41         .area   third  (ABS, BANK=third)
                             42 
                             43         ;--------------------------------------------------
                             44         ; Vector table
                             45         ;--------------------------------------------------
                             46         .bank   fourth  (base=VECTORS, size=ROMEND-VECTORS)
                             47         .area   fourth  (ABS, BANK=fourth)        
                             48 
   FFFA 89 F9                49         .dw     NMI
   FFFC 00 F8                50         .dw     STARTUP
   FFFE 00 F8                51         .dw     STARTUP
                             52 
                             53         .end
