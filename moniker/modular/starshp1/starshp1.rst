                              1 
                              2         .include "../6502/settings.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; You may need to adjust these variables for different targets
                              3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              4 
                              5 ; RAM SETTINGS - usually in zero page
                              6 
                     0000     7 RAMSTRT .equ    0x00    ;start of ram, needs 7 bytes starting here
                     00FF     8 SSTACK	.equ	0xff	;start of stack, needs some memory below this address
                              9 
                             10 ; ROM SETTINGS - usually the last 2K of memory for 6502
                             11 
                     F800    12 STRTADD .equ    0xf800      ; start of chip memory mapping
                             13 
                             14 ; TIMER SETTING
                     0180    15 BIGDEL  .equ    0x0180      ; delay factor
                             16 
                             17 ; I2C ADDRESSING
                     0011    18 I2CRADR .equ    0x11        ; I2C read address  - I2C address 0x08
                     0010    19 I2CWADR .equ    0x10        ; I2C write address - I2C address 0x08
                             20 
                             21 ; VECTORS
                     FFFA    22 VECTORS .equ    STRTADD+0x07fa
                             23 
                             24 
                             25 
                             26 
                              3         .include "../romio/defs.asm"
                              1 ; For Demon Debugger Hardware - Rev D 
                              2 
                     FFA0     3 IOREGR   .equ   STRTADD+0x07a0    ;reserved region for IO READ
                     FFC0     4 IOREGW   .equ   STRTADD+0x07c0    ;reserved region for IO WRITE
                              5 
                     FFA0     6 IOADD    .equ   IOREGR            ;start of region
                              4 
                              5         ; This section must end before the IO Region
                              6         .bank   first   (base=STRTADD, size=IOADD-STRTADD)
                              7         .area   first   (ABS, BANK=first)
                              8 
                              9         .include "../6502/startup.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; This function is called once, and should be used do any game-specific
                              3 ; initialization that is required
                              4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              5 
   F800                       6 ONCE:
                              7 ;       YOUR CODE CAN GO HERE
   F800 60            [ 6]    8         rts
                             10         .include "loop.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; This function is called every time during the polling loop.  It can be
                              3 ; used to run watchdog code, etc.  I have provided a simple delay loop
                              4 ; so that the I2C slave is not overwhelmed
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 
   F801                       7 EVERY:
                              8         ; reset the starshp1 watchdog
   F801 A9 01         [ 2]    9 	lda     #0x01
   F803 8D 06 DC      [ 4]   10 	sta     0xdc06
   F806 A9 FE         [ 2]   11 	lda     #0xfe
   F808 8D 00 CC      [ 4]   12 	sta     0xcc00
   F80B 8D 00 CC      [ 4]   13 	sta     0xcc00
   F80E 8D 00 CC      [ 4]   14 	sta     0xcc00
   F811 8D 00 CC      [ 4]   15 	sta     0xcc00
   F814 8D 00 CC      [ 4]   16 	sta     0xcc00
   F817 8D 00 CC      [ 4]   17 	sta     0xcc00
   F81A 8D 00 CC      [ 4]   18 	sta     0xcc00
   F81D 8D 00 CC      [ 4]   19 	sta     0xcc00
   F820 8D 00 CC      [ 4]   20 	sta     0xcc00
   F823 8D 00 CC      [ 4]   21 	sta     0xcc00
   F826 8D 00 CC      [ 4]   22 	sta     0xcc00
   F829 8D 00 CC      [ 4]   23 	sta     0xcc00
   F82C 8D 00 CC      [ 4]   24 	sta     0xcc00
   F82F 8D 00 CC      [ 4]   25 	sta     0xcc00
   F832 8D 00 CC      [ 4]   26 	sta     0xcc00
   F835 8D 00 CC      [ 4]   27 	sta     0xcc00
   F838 8D 00 CC      [ 4]   28 	sta     0xcc00
   F83B 8D 00 CC      [ 4]   29 	sta     0xcc00
   F83E 8D 00 CC      [ 4]   30 	sta     0xcc00
   F841 8D 00 CC      [ 4]   31 	sta     0xcc00
   F844 8D 06 DC      [ 4]   32 	sta     0xdc06
                             33 
   F847 60            [ 6]   34         rts
                             11         .include "../6502/nmi.asm"
                              1 ; NMI Handler
   F848 40            [ 6]    2 NMI:	rti             ;Don't do anything on an NMI
                             12         .include "../6502/romio.asm" 
   F849 A5 00         [ 3]    1 SETSCL:	lda	OUTBUF
   F84B 09 01         [ 2]    2 	ora	#0x01
   F84D 85 00         [ 3]    3         sta     OUTBUF
   F84F AA            [ 2]    4         tax
   F850 BD C0 FF      [ 5]    5         lda     IOREGW,X
   F853 20 85 F8      [ 6]    6 	jsr	I2CDLY
   F856 60            [ 6]    7 	rts
                              8 
   F857 A5 00         [ 3]    9 CLRSCL:	lda	OUTBUF
   F859 29 1E         [ 2]   10     and	#0x1e
   F85B 85 00         [ 3]   11     sta	OUTBUF
   F85D AA            [ 2]   12         tax
   F85E BD C0 FF      [ 5]   13         lda     IOREGW,X
   F861 60            [ 6]   14 	rts
                             15 
   F862 A5 00         [ 3]   16 SETSDA:	lda	OUTBUF
   F864 29 1D         [ 2]   17 	and	#0x1d
   F866 85 00         [ 3]   18         sta     OUTBUF
   F868 AA            [ 2]   19         tax
   F869 BD C0 FF      [ 5]   20         lda     IOREGW,X
   F86C 20 85 F8      [ 6]   21 	jsr	I2CDLY
   F86F 60            [ 6]   22 	rts
                             23 
   F870 A5 00         [ 3]   24 CLRSDA:	lda	OUTBUF
   F872 09 02         [ 2]   25 	ora	#0x02
   F874 85 00         [ 3]   26         sta     OUTBUF
   F876 AA            [ 2]   27         tax
   F877 BD C0 FF      [ 5]   28         lda     IOREGW,X
   F87A 20 85 F8      [ 6]   29 	jsr	I2CDLY
   F87D 60            [ 6]   30 	rts
                             31 
   F87E A6 00         [ 3]   32 READSDA:	ldx	OUTBUF
   F880 BD A0 FF      [ 5]   33         lda     IOREGR,X
   F883 6A            [ 2]   34         ror
   F884 60            [ 6]   35 	rts				
                             13         .include "../6502/main.asm"
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
                             13 ; Delay for half a bit time
   F885 60            [ 6]   14 I2CDLY:	rts		; TBD - this is plenty?
                             15 
                             16 ; I2C Start Condition
   F886                      17 I2CSTART:
   F886 20 70 F8      [ 6]   18         jsr    CLRSDA      
   F889 20 57 F8      [ 6]   19         jsr    CLRSCL
   F88C 60            [ 6]   20         rts
                             21 
                             22 ; I2C Stop Condition
                             23 ; Uses HL
                             24 ; Destroys A
   F88D                      25 I2CSTOP:
   F88D 20 70 F8      [ 6]   26         jsr    CLRSDA
   F890 20 49 F8      [ 6]   27         jsr    SETSCL
   F893 20 62 F8      [ 6]   28         jsr    SETSDA
   F896 60            [ 6]   29         rts
                             30         
   F897                      31 I2CRBIT:
   F897 20 62 F8      [ 6]   32 	jsr	SETSDA
   F89A 20 49 F8      [ 6]   33 	jsr	SETSCL
   F89D 20 7E F8      [ 6]   34 	jsr	READSDA	; sets/clears carry flag
   F8A0 20 57 F8      [ 6]   35 	jsr     CLRSCL
   F8A3 60            [ 6]   36 	rts		; carry flag still good here
                             37 
   F8A4                      38 I2CWBIT:
   F8A4 90 06         [ 4]   39 	bcc	DOCLR
   F8A6 20 62 F8      [ 6]   40 	jsr	SETSDA
   F8A9 4C AF F8      [ 3]   41 	jmp	AHEAD
   F8AC                      42 DOCLR:
   F8AC 20 70 F8      [ 6]   43 	jsr	CLRSDA
   F8AF                      44 AHEAD:
   F8AF 20 49 F8      [ 6]   45 	jsr	SETSCL
   F8B2 20 57 F8      [ 6]   46 	jsr	CLRSCL
   F8B5 60            [ 6]   47 	rts
                             48         
   F8B6                      49 I2CWBYTE:
   F8B6 48            [ 3]   50 	pha
   F8B7 A9 08         [ 2]   51 	lda	#0x08
   F8B9 85 01         [ 3]   52 	sta	B
   F8BB 68            [ 4]   53 	pla
   F8BC                      54 ILOOP:
   F8BC 2A            [ 2]   55 	rol
   F8BD 48            [ 3]   56 	pha
   F8BE 20 A4 F8      [ 6]   57 	jsr	I2CWBIT
   F8C1 68            [ 4]   58 	pla
   F8C2 C6 01         [ 5]   59 	dec	B
   F8C4 D0 F6         [ 4]   60 	bne	ILOOP
   F8C6 20 97 F8      [ 6]   61 	jsr	I2CRBIT
   F8C9 60            [ 6]   62 	rts
                             63 	
   F8CA                      64 I2CRBYTE:
   F8CA A9 08         [ 2]   65         lda	#0x08
   F8CC 85 01         [ 3]   66 	sta	B
   F8CE A9 00         [ 2]   67 	lda	#0x00
   F8D0 85 02         [ 3]   68 	sta	C
   F8D2                      69 LOOP3:
   F8D2 20 97 F8      [ 6]   70         jsr     I2CRBIT     ; get bit in carry flag
   F8D5 26 02         [ 5]   71         rol     C           ; rotate carry into bit0 of C register
   F8D7 C6 01         [ 5]   72         dec	B
   F8D9 D0 F7         [ 4]   73         bne    	LOOP3
   F8DB 18            [ 2]   74         clc           	    ; clear carry flag              
   F8DC 20 A4 F8      [ 6]   75         jsr   	I2CWBIT
   F8DF A5 02         [ 3]   76         lda  	C
   F8E1 60            [ 6]   77         rts
                             78 
   F8E2                      79 I2CRREQ:
   F8E2 20 86 F8      [ 6]   80         jsr     I2CSTART
   F8E5 A9 11         [ 2]   81         lda	#I2CRADR
   F8E7 20 B6 F8      [ 6]   82         jsr     I2CWBYTE
   F8EA B0 17         [ 4]   83         bcs     SKIP
   F8EC 20 CA F8      [ 6]   84         jsr     I2CRBYTE
   F8EF 85 03         [ 3]   85         sta     CMDBUF0
   F8F1 20 CA F8      [ 6]   86         jsr     I2CRBYTE
   F8F4 85 04         [ 3]   87         sta     CMDBUF1
   F8F6 20 CA F8      [ 6]   88         jsr     I2CRBYTE
   F8F9 85 05         [ 3]   89         sta     CMDBUF2
   F8FB 20 CA F8      [ 6]   90         jsr     I2CRBYTE
   F8FE 85 06         [ 3]   91         sta     CMDBUF3
   F900 4C 17 F9      [ 3]   92         jmp     ENDI2C
                             93     
   F903                      94 SKIP:                       ; If no device present, fake an idle response
   F903 A9 2E         [ 2]   95         lda     #0x2e  ; '.'
   F905 85 03         [ 3]   96         sta     CMDBUF0
   F907 4C 17 F9      [ 3]   97         jmp     ENDI2C
                             98 
   F90A                      99 I2CSRESP:
   F90A 48            [ 3]  100         pha
   F90B 20 86 F8      [ 6]  101         jsr     I2CSTART
   F90E A9 10         [ 2]  102         lda     #I2CWADR
   F910 20 B6 F8      [ 6]  103         jsr     I2CWBYTE
   F913 68            [ 4]  104         pla
   F914 20 B6 F8      [ 6]  105         jsr     I2CWBYTE
   F917                     106 ENDI2C:
   F917 20 8D F8      [ 6]  107         jsr     I2CSTOP
   F91A 60            [ 6]  108         rts
                            109 
   F91B                     110 POLL:
   F91B 20 E2 F8      [ 6]  111         jsr     I2CRREQ
   F91E A5 03         [ 3]  112         lda     CMDBUF0
   F920 C9 52         [ 2]  113         cmp     #0x52    	; 'R' - Read memory
   F922 F0 0A         [ 4]  114         beq     MREAD
   F924 C9 57         [ 2]  115         cmp     #0x57    	; 'W' - Write memory
   F926 F0 10         [ 4]  116         beq	MWRITE
   F928 C9 43         [ 2]  117         cmp     #0x43    	; 'C' - Call subroutine
   F92A F0 26         [ 4]  118         beq	REMCALL
   F92C 18            [ 2]  119         clc
   F92D 60            [ 6]  120         rts
                            121 
   F92E                     122 MREAD:
   F92E 20 44 F9      [ 6]  123         jsr     LOADBC
   F931 A0 00         [ 2]  124         ldy	#0x00
   F933 B1 01         [ 6]  125         lda	[B],Y
   F935 4C 4D F9      [ 3]  126         jmp     SRESP
   F938                     127 MWRITE:
   F938 20 44 F9      [ 6]  128         jsr     LOADBC
   F93B A5 06         [ 3]  129         lda     CMDBUF3
   F93D 91 01         [ 6]  130         sta     [B],Y
   F93F A9 57         [ 2]  131         lda     #0x57  	;'W'
   F941 4C 4D F9      [ 3]  132         jmp     SRESP
   F944                     133 LOADBC:
   F944 A5 05         [ 3]  134 	lda	CMDBUF2
   F946 85 01         [ 3]  135 	sta	B
   F948 A5 04         [ 3]  136 	lda	CMDBUF1
   F94A 85 02         [ 3]  137 	sta	C
   F94C 60            [ 6]  138 	rts
                            139 	
   F94D                     140 SRESP:
   F94D 20 0A F9      [ 6]  141         jsr    I2CSRESP
   F950                     142 RHERE:
   F950 38            [ 2]  143         sec
   F951 60            [ 6]  144         rts
   F952                     145 REMCALL:
   F952 A9 F9         [ 2]  146 	lda	#>(START-1)
   F954 48            [ 3]  147         pha
   F955 A9 5D         [ 2]  148         lda	#<(START-1)
   F957 48            [ 3]  149         pha
   F958 20 44 F9      [ 6]  150         jsr     LOADBC
   F95B 6C 01 00      [ 5]  151         jmp     [B]
                            152         
                            153 ;;;;;;;;;;
                            154 	
   F95E                     155 START:
   F95E 78            [ 2]  156         sei             ; disable interrupts
   F95F A2 FF         [ 2]  157 	ldx	#SSTACK
   F961 9A            [ 2]  158 	txs		; Init stack
   F962 D8            [ 2]  159 	cld		; No Decimal
   F963 A9 00         [ 2]  160         lda     #0x00
   F965 85 00         [ 3]  161         sta     OUTBUF
   F967 20 00 F8      [ 6]  162         jsr     ONCE
                            163 
                            164 ; Main routine
   F96A                     165 MAIN:
   F96A 20 01 F8      [ 6]  166         jsr     EVERY
   F96D 20 1B F9      [ 6]  167         jsr     POLL
   F970 B0 F8         [ 4]  168         bcs     MAIN
   F972 A9 01         [ 2]  169         lda	#BIGDEL>>8
   F974 85 01         [ 3]  170         sta	B
   F976 A9 80         [ 2]  171         lda	#BIGDEL%256
   F978 85 02         [ 3]  172         sta	C
   F97A                     173 MLOOP:
   F97A A5 02         [ 3]  174         lda	C
   F97C F0 05         [ 4]  175         beq	DECBOTH
   F97E C6 02         [ 5]  176         dec	C
   F980 4C 7A F9      [ 3]  177         jmp	MLOOP
   F983                     178 DECBOTH:
   F983 A5 01         [ 3]  179 	lda	B
   F985 F0 E3         [ 4]  180 	beq	MAIN
   F987 C6 02         [ 5]  181 	dec	C
   F989 C6 01         [ 5]  182 	dec	B
   F98B 4C 7A F9      [ 3]  183 	jmp	MLOOP
                             14 
                             15         .include "../romio/table.asm"
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
   FFC0 00 01 02 03 04 05    24         .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        06 07 08 09 0A 0B
        0C 0D 0E 0F
   FFD0 10 11 12 13 14 15    25         .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
        16 17 18 19 1A 1B
        1C 1D 1E 1F
                             26 
                             16 
                             17         .include "../6502/vectors.asm"
                              1 	
                              2         .bank   vectorbank   (base=VECTORS, size=0x06)
                              3         .area   vectorarea   (ABS, BANK=vectorbank)
                              4 
   FFFA 48 F8                 5 	.dw	NMI
   FFFC 5E F9                 6 	.dw	START
   FFFE 5E F9                 7 	.dw	START
