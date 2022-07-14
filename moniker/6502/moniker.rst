                              1 ;
                              2 ; Moniker - 6502 Version
                              3 ; by Frank Palazzolo
                              4 ; For Atari Asteroids
                              5 ;
                              6 ; This code replaces ROM J2 on my Asteroids
                              7 ;
                              8 ; SCL  - WRITE 0x3200, bit0 (0x01) 2 player start lamp - active low only because led is wired to +5V
                              9 ; DOUT - WRITE 0x3200, bit1 (0x02) 1 player start lamp - active low only because led is wired to +5V
                             10 ; DIN  - READ  0x2405, bit7 (0x80) thrust button - inverted on input
                             11 
                             12         .area   CODE1   (ABS)   ; ASXXXX directive, absolute addressing
                             13 
                     2800    14 DIP7	.equ	0x2800	;bit0 = DIP switch 7
                     3200    15 LEDS	.equ	0x3200	;bit0 = 2 player start lamp
                             16 			;bit1 = 1 player start lamp
                             17 		
                     0000    18 LEDBUF	.equ	0x00	;buffer for lamps
                     0001    19 B	.equ	0x01	;general purpose
                     0002    20 C	.equ	0x02	;general purpose
                     0003    21 CMDBUF0 .equ	0x03	;command buffer
                     0004    22 CMDBUF1 .equ	0x04	;command buffer
                     0005    23 CMDBUF2 .equ	0x05	;command buffer
                     0006    24 CMDBUF3 .equ	0x06	;command buffer
                             25 
                     00FE    26 SSTACK	.equ	0xfe	;start of stack
                             27 
                     0011    28 I2CRADR .equ     0x11    ;I2C read address  - I2C address 0x08
                     0010    29 I2CWADR .equ     0x10    ;I2C write address - I2C address 0x08
                             30 
                     0180    31 BIGDEL	.equ	0x0180
                             32 
   7800                      33 	.org	0x7800	;start of rom at j2
                             34 	
   7800 40            [ 6]   35 NMI:	rti
                             36 
   7801 A5 00         [ 3]   37 SETSCL:	lda	LEDBUF
   7803 09 01         [ 2]   38 	ora	#0x01
   7805 85 00         [ 3]   39 	sta	LEDBUF
   7807 8D 00 32      [ 4]   40 	sta	LEDS
   780A 20 37 78      [ 6]   41 	jsr	I2CDLY
   780D 60            [ 6]   42 	rts
                             43 
   780E A5 00         [ 3]   44 CLRSCL:	lda	LEDBUF
   7810 29 FE         [ 2]   45 	and	#0xfe
   7812 85 00         [ 3]   46 	sta	LEDBUF
   7814 8D 00 32      [ 4]   47 	sta	LEDS
   7817 60            [ 6]   48 	rts
                             49 	
   7818 A5 00         [ 3]   50 SETSDA:	lda	LEDBUF
   781A 29 FD         [ 2]   51 	and	#0xfd
   781C 85 00         [ 3]   52 	sta	LEDBUF
   781E 8D 00 32      [ 4]   53 	sta	LEDS
   7821 20 37 78      [ 6]   54 	jsr	I2CDLY
   7824 60            [ 6]   55 	rts
                             56 
   7825 A5 00         [ 3]   57 CLRSDA:	lda	LEDBUF
   7827 09 02         [ 2]   58 	ora	#0x02
   7829 85 00         [ 3]   59 	sta	LEDBUF
   782B 8D 00 32      [ 4]   60 	sta	LEDS
   782E 20 37 78      [ 6]   61 	jsr	I2CDLY
   7831 60            [ 6]   62 	rts
                             63 
   7832                      64 READSDA:        
   7832 AD 00 28      [ 4]   65         lda	DIP7
   7835 6A            [ 2]   66 	ror			
   7836 60            [ 6]   67 	rts				
                             68 
                             69 ; Delay for half a bit time
   7837 60            [ 6]   70 I2CDLY:	rts		; TBD - this is plenty?
                             71 
                             72 ; I2C Start Condition
   7838                      73 I2CSTART:
   7838 20 25 78      [ 6]   74         jsr    CLRSDA      
   783B 20 0E 78      [ 6]   75         jsr    CLRSCL
   783E 60            [ 6]   76         rts
                             77 
                             78 ; I2C Stop Condition
                             79 ; Uses HL
                             80 ; Destroys A
   783F                      81 I2CSTOP:
   783F 20 25 78      [ 6]   82         jsr    CLRSDA
   7842 20 01 78      [ 6]   83         jsr    SETSCL
   7845 20 18 78      [ 6]   84         jsr    SETSDA
   7848 60            [ 6]   85         rts
                             86         
   7849                      87 I2CRBIT:
   7849 20 18 78      [ 6]   88 	jsr	SETSDA
   784C 20 01 78      [ 6]   89 	jsr	SETSCL
   784F 20 32 78      [ 6]   90 	jsr	READSDA	; sets/clears carry flag
   7852 20 0E 78      [ 6]   91 	jsr     CLRSCL
   7855 60            [ 6]   92 	rts		; carry flag still good here
                             93 
   7856                      94 I2CWBIT:
   7856 90 06         [ 4]   95 	bcc	DOCLR
   7858 20 18 78      [ 6]   96 	jsr	SETSDA
   785B 4C 61 78      [ 3]   97 	jmp	AHEAD
   785E                      98 DOCLR:
   785E 20 25 78      [ 6]   99 	jsr	CLRSDA
   7861                     100 AHEAD:
   7861 20 01 78      [ 6]  101 	jsr	SETSCL
   7864 20 0E 78      [ 6]  102 	jsr	CLRSCL
   7867 60            [ 6]  103 	rts
                            104         
   7868                     105 I2CWBYTE:
   7868 48            [ 3]  106 	pha
   7869 A9 08         [ 2]  107 	lda	#0x08
   786B 85 01         [ 3]  108 	sta	B
   786D 68            [ 4]  109 	pla
   786E                     110 ILOOP:
   786E 2A            [ 2]  111 	rol
   786F 48            [ 3]  112 	pha
   7870 20 56 78      [ 6]  113 	jsr	I2CWBIT
   7873 68            [ 4]  114 	pla
   7874 C6 01         [ 5]  115 	dec	B
   7876 D0 F6         [ 4]  116 	bne	ILOOP
   7878 20 49 78      [ 6]  117 	jsr	I2CRBIT
   787B 60            [ 6]  118 	rts
                            119 	
   787C                     120 I2CRBYTE:
   787C A9 08         [ 2]  121         lda	#0x08
   787E 85 01         [ 3]  122 	sta	B
   7880 A9 00         [ 2]  123 	lda	#0x00
   7882 85 02         [ 3]  124 	sta	C
   7884                     125 LOOP3:
   7884 20 49 78      [ 6]  126         jsr     I2CRBIT     ; get bit in carry flag
   7887 26 02         [ 5]  127         rol     C           ; rotate carry into bit0 of C register
   7889 C6 01         [ 5]  128         dec	B
   788B D0 F7         [ 4]  129         bne    	LOOP3
   788D 18            [ 2]  130         clc           	    ; clear carry flag              
   788E 20 56 78      [ 6]  131         jsr   	I2CWBIT
   7891 A5 02         [ 3]  132         lda  	C
   7893 60            [ 6]  133         rts
                            134 
   7894                     135 I2CRREQ:
   7894 20 38 78      [ 6]  136         jsr     I2CSTART
   7897 A9 11         [ 2]  137         lda	#I2CRADR
   7899 20 68 78      [ 6]  138         jsr     I2CWBYTE
   789C B0 17         [ 4]  139         bcs     SKIP
   789E 20 7C 78      [ 6]  140         jsr     I2CRBYTE
   78A1 85 03         [ 3]  141         sta     CMDBUF0
   78A3 20 7C 78      [ 6]  142         jsr     I2CRBYTE
   78A6 85 04         [ 3]  143         sta     CMDBUF1
   78A8 20 7C 78      [ 6]  144         jsr     I2CRBYTE
   78AB 85 05         [ 3]  145         sta     CMDBUF2
   78AD 20 7C 78      [ 6]  146         jsr     I2CRBYTE
   78B0 85 06         [ 3]  147         sta     CMDBUF3
   78B2 4C C9 78      [ 3]  148         jmp     ENDI2C
                            149     
   78B5                     150 SKIP:                       ; If no device present, fake an idle response
   78B5 A9 2E         [ 2]  151         lda     #0x2e  ; '.'
   78B7 85 03         [ 3]  152         sta     CMDBUF0
   78B9 4C C9 78      [ 3]  153         jmp     ENDI2C
                            154 
   78BC                     155 I2CSRESP:
   78BC 48            [ 3]  156         pha
   78BD 20 38 78      [ 6]  157         jsr     I2CSTART
   78C0 A9 10         [ 2]  158         lda     #I2CWADR
   78C2 20 68 78      [ 6]  159         jsr     I2CWBYTE
   78C5 68            [ 4]  160         pla
   78C6 20 68 78      [ 6]  161         jsr     I2CWBYTE
   78C9                     162 ENDI2C:
   78C9 20 3F 78      [ 6]  163         jsr     I2CSTOP
   78CC 60            [ 6]  164         rts
                            165 
   78CD                     166 POLL:
   78CD 20 94 78      [ 6]  167         jsr     I2CRREQ
   78D0 A5 03         [ 3]  168         lda     CMDBUF0
   78D2 C9 52         [ 2]  169         cmp     #0x52    	; 'R' - Read memory
   78D4 F0 0A         [ 4]  170         beq     MREAD
   78D6 C9 57         [ 2]  171         cmp     #0x57    	; 'W' - Write memory
   78D8 F0 10         [ 4]  172         beq	MWRITE
   78DA C9 43         [ 2]  173         cmp     #0x43    	; 'C' - Call subroutine
   78DC F0 26         [ 4]  174         beq	REMCALL
   78DE 18            [ 2]  175         clc
   78DF 60            [ 6]  176         rts
                            177 
   78E0                     178 MREAD:
   78E0 20 F6 78      [ 6]  179         jsr     LOADBC
   78E3 A0 00         [ 2]  180         ldy	#0x00
   78E5 B1 01         [ 6]  181         lda	[B],Y
   78E7 4C FF 78      [ 3]  182         jmp     SRESP
   78EA                     183 MWRITE:
   78EA 20 F6 78      [ 6]  184         jsr     LOADBC
   78ED A5 06         [ 3]  185         lda     CMDBUF3
   78EF 91 01         [ 6]  186         sta     [B],Y
   78F1 A9 57         [ 2]  187         lda     #0x57  	;'W'
   78F3 4C FF 78      [ 3]  188         jmp     SRESP
   78F6                     189 LOADBC:
   78F6 A5 05         [ 3]  190 	lda	CMDBUF2
   78F8 85 01         [ 3]  191 	sta	B
   78FA A5 04         [ 3]  192 	lda	CMDBUF1
   78FC 85 02         [ 3]  193 	sta	C
   78FE 60            [ 6]  194 	rts
                            195 	
   78FF                     196 SRESP:
   78FF 20 BC 78      [ 6]  197         jsr    I2CSRESP
   7902                     198 RHERE:
   7902 38            [ 2]  199         sec
   7903 60            [ 6]  200         rts
   7904                     201 REMCALL:
   7904 A9 79         [ 2]  202 	lda	#>(START-1)
   7906 48            [ 3]  203         pha
   7907 A9 0F         [ 2]  204 	lda	#<(START-1)
   7909 48            [ 3]  205         pha
   790A 20 F6 78      [ 6]  206         jsr     LOADBC
   790D 6C 01 00      [ 5]  207         jmp     [B]
                            208         
                            209 ;;;;;;;;;;
                            210 	
   7910                     211 START:	
   7910 A2 FE         [ 2]  212 	ldx	#SSTACK
   7912 9A            [ 2]  213 	txs		; Init stack
   7913 D8            [ 2]  214 	cld		; No Decimal
                            215 
                            216 ; Main routine
   7914                     217 MAIN:
   7914 20 CD 78      [ 6]  218         jsr     POLL
   7917 B0 FB         [ 4]  219         bcs     MAIN
                            220         
   7919 A9 01         [ 2]  221         lda	#BIGDEL>>8
   791B 85 01         [ 3]  222         sta	B
   791D A9 80         [ 2]  223         lda	#BIGDEL%256
   791F 85 02         [ 3]  224         sta	C
   7921                     225 MLOOP:
   7921 A5 02         [ 3]  226         lda	C
   7923 F0 05         [ 4]  227         beq	DECBOTH
   7925 C6 02         [ 5]  228         dec	C
   7927 4C 21 79      [ 3]  229         jmp	MLOOP
   792A                     230 DECBOTH:
   792A A5 01         [ 3]  231 	lda	B
   792C F0 E6         [ 4]  232 	beq	MAIN
   792E C6 02         [ 5]  233 	dec	C
   7930 C6 01         [ 5]  234 	dec	B
   7932 4C 21 79      [ 3]  235 	jmp	MLOOP
                            236 
   7FFA                     237 	.org	0x7ffa
   7FFA 00 78               238 	.dw	NMI
   7FFC 10 79               239 	.dw	START
   7FFE 10 79               240 	.dw	START
                            241 	
                            242 	
                            243 	
