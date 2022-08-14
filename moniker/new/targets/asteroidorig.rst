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
                             39 ;       YOUR CODE CAN GO HERE
                             40         rts
                             41         .endm        
                             42 
                             43 ;--------------------------------------------------------------------------
                             44 ; ROM TEMPLATE - this defines the rom layout, and which kind of io
                             45 ;--------------------------------------------------------------------------
                             46         .include "../rom_templates/asteroid_tether_f800_2k.asm"
                              1 
                              2          
                     F800     3 STRTADD .equ    0xf800      ; start of chip memory mapping
                     0800     4 ROMSIZE .equ    0x0800      ; 2K ROM 
                              5 
                              6         .include "../dd/dd.def"
                              1 
                     0000     2 ROMEND  .equ    STRTADD+ROMSIZE
                              3 
                              4 
                              7         .include "../dd/6502.def"
                              1 ; Same for all 6502s
                     FFFA     2 VECTORS .equ    0xfffa      ; location of Vector table
                              8 
                              9 ; TIMER SETTING
                     0180    10 BIGDEL  .equ    0x0180      ; delay factor
                             11 
                             12         .bank   first   (base=STRTADD, size=VECTORS)
                             13         .area   first   (ABS, BANK=first)
   F800                      14 STARTUP:
                             15         STARTUP_MACRO
   F800 78            [ 2]    1         sei              ; Disable interrupts - we don't handle them
   F801 A2 FF         [ 2]    2         ldx     #SSTACK  ; hset up the stack
   F803 9A            [ 2]    3         txs
   F804 D8            [ 2]    4         cld              ; No Decimal
                              5 ;       YOUR CODE CAN GO HERE
                             16 
                             17         ; Entry to main routine here
                             18         .include "../dd/6502_main.asm"
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
   F82E 20 2B F9      [ 6]   46         jsr    CLRSDA      
   F831 20 14 F9      [ 6]   47         jsr    CLRSCL
   F834 60            [ 6]   48         rts
                             49 
                             50 ; I2C Stop Condition
                             51 ; Uses HL
                             52 ; Destroys A
   F835                      53 I2CSTOP:
   F835 20 2B F9      [ 6]   54         jsr    CLRSDA
   F838 20 07 F9      [ 6]   55         jsr    SETSCL
   F83B 20 1E F9      [ 6]   56         jsr    SETSDA
   F83E 60            [ 6]   57         rts
                             58         
   F83F                      59 I2CRBIT:
   F83F 20 1E F9      [ 6]   60 	jsr	SETSDA
   F842 20 07 F9      [ 6]   61 	jsr	SETSCL
   F845 20 38 F9      [ 6]   62 	jsr	READSDA	; sets/clears carry flag
   F848 20 14 F9      [ 6]   63 	jsr     CLRSCL
   F84B 60            [ 6]   64 	rts		; carry flag still good here
                             65 
   F84C                      66 I2CWBIT:
   F84C 90 06         [ 4]   67 	bcc	DOCLR
   F84E 20 1E F9      [ 6]   68 	jsr	SETSDA
   F851 4C 57 F8      [ 3]   69 	jmp	AHEAD
   F854                      70 DOCLR:
   F854 20 2B F9      [ 6]   71 	jsr	CLRSDA
   F857                      72 AHEAD:
   F857 20 07 F9      [ 6]   73 	jsr	SETSCL
   F85A 20 14 F9      [ 6]   74 	jsr	CLRSCL
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
                             19         
   F906                      20 EVERY:
                             21         EVERY_MACRO
                              1 ;       YOUR CODE CAN GO HERE
   F906 60            [ 6]    2         rts
                             22 
                             23         ; Routines for tether io here
                             24         .include "../io/asteroid_tether.asm"
                              1 
                              2 ; SCL  - WRITE 0x3200, bit0 (0x01) 2 player start lamp - active low only because led is wired to +5V
                              3 ; DOUT - WRITE 0x3200, bit1 (0x02) 1 player start lamp - active low only because led is wired to +5V
                              4 ; DIN  - READ  0x2405, bit7 (0x80) thrust button - inverted on input
                              5 
                     2800     6 DIP7	.equ	0x2800	;bit0 = DIP switch 7
                     3200     7 LEDS	.equ	0x3200	;bit0 = 2 player start lamp
                              8 			;bit1 = 1 player start lamp
                              9 		
                     0000    10 LEDBUF	.equ	OUTBUF	;buffer for lamps
                             11 
   F907 A5 00         [ 3]   12 SETSCL:	lda	LEDBUF
   F909 09 01         [ 2]   13 	ora	#0x01
   F90B 85 00         [ 3]   14 	sta	LEDBUF
   F90D 8D 00 32      [ 4]   15 	sta	LEDS
   F910 20 2D F8      [ 6]   16 	jsr	I2CDLY
   F913 60            [ 6]   17 	rts
                             18 
   F914 A5 00         [ 3]   19 CLRSCL:	lda	LEDBUF
   F916 29 FE         [ 2]   20 	and	#0xfe
   F918 85 00         [ 3]   21 	sta	LEDBUF
   F91A 8D 00 32      [ 4]   22 	sta	LEDS
   F91D 60            [ 6]   23 	rts
                             24 	
   F91E A5 00         [ 3]   25 SETSDA:	lda	LEDBUF
   F920 29 FD         [ 2]   26 	and	#0xfd
   F922 85 00         [ 3]   27 	sta	LEDBUF
   F924 8D 00 32      [ 4]   28 	sta	LEDS
   F927 20 2D F8      [ 6]   29 	jsr	I2CDLY
   F92A 60            [ 6]   30 	rts
                             31 
   F92B A5 00         [ 3]   32 CLRSDA:	lda	LEDBUF
   F92D 09 02         [ 2]   33 	ora	#0x02
   F92F 85 00         [ 3]   34 	sta	LEDBUF
   F931 8D 00 32      [ 4]   35 	sta	LEDS
   F934 20 2D F8      [ 6]   36 	jsr	I2CDLY
   F937 60            [ 6]   37 	rts
                             38 
   F938                      39 READSDA:        
   F938 AD 00 28      [ 4]   40         lda	DIP7
   F93B 6A            [ 2]   41 	ror			
   F93C 60            [ 6]   42 	rts		
                             43     
                             25 
   F93D                      26 NMI:
                             27         NMI_MACRO
   F93D 40            [ 6]    1         RTI
                             28 
                             29         ;--------------------------------------------------
                             30         ; Vector table
                             31         ;--------------------------------------------------
                             32         .bank   second  (base=VECTORS, size=ROMEND-VECTORS)
                             33         .area   second  (ABS, BANK=second)        
                             34 
   FFFA 3D F9                35         .dw     NMI
   FFFC 00 F8                36         .dw     STARTUP
   FFFE 00 F8                37         .dw     STARTUP
                             38 
                             39         .end
