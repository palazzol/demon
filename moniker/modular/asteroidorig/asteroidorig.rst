                              1 
                              2 ; This code replaces ROM J2 on my Asteroids
                              3 
                              4         .include "../6502/settings.asm"
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
                              5 
                              6         .bank   first   (base=STRTADD, size=VECTORS-STRTADD)
                              7         .area   first   (ABS, BANK=first)
                              8 
                              9         .include "../6502/nmi.asm"
                              1 ; NMI Handler
   F800 40            [ 6]    2 NMI:	rti             ;Don't do anything on an NMI
                             10         .include "../6502/startup.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; This function is called once, and should be used do any game-specific
                              3 ; initialization that is required
                              4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              5 
   F801                       6 ONCE:
                              7 ;       YOUR CODE CAN GO HERE
   F801 60            [ 6]    8         rts
                             11         .include "../6502/loop.asm"
                              1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              2 ; This function is called every time during the polling loop.  It can be
                              3 ; used to run watchdog code, etc.  I have provided a simple delay loop
                              4 ; so that the I2C slave is not overwhelmed
                              5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              6 
   F802                       7 EVERY:
                              8 ;       YOUR CODE CAN GO HERE
   F802 60            [ 6]    9         rts
                             12         .include "io.asm"
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
   F803 A5 00         [ 3]   12 SETSCL:	lda	LEDBUF
   F805 09 01         [ 2]   13 	ora	#0x01
   F807 85 00         [ 3]   14 	sta	LEDBUF
   F809 8D 00 32      [ 4]   15 	sta	LEDS
   F80C 20 39 F8      [ 6]   16 	jsr	I2CDLY
   F80F 60            [ 6]   17 	rts
                             18 
   F810 A5 00         [ 3]   19 CLRSCL:	lda	LEDBUF
   F812 29 FE         [ 2]   20 	and	#0xfe
   F814 85 00         [ 3]   21 	sta	LEDBUF
   F816 8D 00 32      [ 4]   22 	sta	LEDS
   F819 60            [ 6]   23 	rts
                             24 	
   F81A A5 00         [ 3]   25 SETSDA:	lda	LEDBUF
   F81C 29 FD         [ 2]   26 	and	#0xfd
   F81E 85 00         [ 3]   27 	sta	LEDBUF
   F820 8D 00 32      [ 4]   28 	sta	LEDS
   F823 20 39 F8      [ 6]   29 	jsr	I2CDLY
   F826 60            [ 6]   30 	rts
                             31 
   F827 A5 00         [ 3]   32 CLRSDA:	lda	LEDBUF
   F829 09 02         [ 2]   33 	ora	#0x02
   F82B 85 00         [ 3]   34 	sta	LEDBUF
   F82D 8D 00 32      [ 4]   35 	sta	LEDS
   F830 20 39 F8      [ 6]   36 	jsr	I2CDLY
   F833 60            [ 6]   37 	rts
                             38 
   F834                      39 READSDA:        
   F834 AD 00 28      [ 4]   40         lda	DIP7
   F837 6A            [ 2]   41 	ror			
   F838 60            [ 6]   42 	rts				
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
   F839 60            [ 6]   14 I2CDLY:	rts		; TBD - this is plenty?
                             15 
                             16 ; I2C Start Condition
   F83A                      17 I2CSTART:
   F83A 20 27 F8      [ 6]   18         jsr    CLRSDA      
   F83D 20 10 F8      [ 6]   19         jsr    CLRSCL
   F840 60            [ 6]   20         rts
                             21 
                             22 ; I2C Stop Condition
                             23 ; Uses HL
                             24 ; Destroys A
   F841                      25 I2CSTOP:
   F841 20 27 F8      [ 6]   26         jsr    CLRSDA
   F844 20 03 F8      [ 6]   27         jsr    SETSCL
   F847 20 1A F8      [ 6]   28         jsr    SETSDA
   F84A 60            [ 6]   29         rts
                             30         
   F84B                      31 I2CRBIT:
   F84B 20 1A F8      [ 6]   32 	jsr	SETSDA
   F84E 20 03 F8      [ 6]   33 	jsr	SETSCL
   F851 20 34 F8      [ 6]   34 	jsr	READSDA	; sets/clears carry flag
   F854 20 10 F8      [ 6]   35 	jsr     CLRSCL
   F857 60            [ 6]   36 	rts		; carry flag still good here
                             37 
   F858                      38 I2CWBIT:
   F858 90 06         [ 4]   39 	bcc	DOCLR
   F85A 20 1A F8      [ 6]   40 	jsr	SETSDA
   F85D 4C 63 F8      [ 3]   41 	jmp	AHEAD
   F860                      42 DOCLR:
   F860 20 27 F8      [ 6]   43 	jsr	CLRSDA
   F863                      44 AHEAD:
   F863 20 03 F8      [ 6]   45 	jsr	SETSCL
   F866 20 10 F8      [ 6]   46 	jsr	CLRSCL
   F869 60            [ 6]   47 	rts
                             48         
   F86A                      49 I2CWBYTE:
   F86A 48            [ 3]   50 	pha
   F86B A9 08         [ 2]   51 	lda	#0x08
   F86D 85 01         [ 3]   52 	sta	B
   F86F 68            [ 4]   53 	pla
   F870                      54 ILOOP:
   F870 2A            [ 2]   55 	rol
   F871 48            [ 3]   56 	pha
   F872 20 58 F8      [ 6]   57 	jsr	I2CWBIT
   F875 68            [ 4]   58 	pla
   F876 C6 01         [ 5]   59 	dec	B
   F878 D0 F6         [ 4]   60 	bne	ILOOP
   F87A 20 4B F8      [ 6]   61 	jsr	I2CRBIT
   F87D 60            [ 6]   62 	rts
                             63 	
   F87E                      64 I2CRBYTE:
   F87E A9 08         [ 2]   65         lda	#0x08
   F880 85 01         [ 3]   66 	sta	B
   F882 A9 00         [ 2]   67 	lda	#0x00
   F884 85 02         [ 3]   68 	sta	C
   F886                      69 LOOP3:
   F886 20 4B F8      [ 6]   70         jsr     I2CRBIT     ; get bit in carry flag
   F889 26 02         [ 5]   71         rol     C           ; rotate carry into bit0 of C register
   F88B C6 01         [ 5]   72         dec	B
   F88D D0 F7         [ 4]   73         bne    	LOOP3
   F88F 18            [ 2]   74         clc           	    ; clear carry flag              
   F890 20 58 F8      [ 6]   75         jsr   	I2CWBIT
   F893 A5 02         [ 3]   76         lda  	C
   F895 60            [ 6]   77         rts
                             78 
   F896                      79 I2CRREQ:
   F896 20 3A F8      [ 6]   80         jsr     I2CSTART
   F899 A9 11         [ 2]   81         lda	#I2CRADR
   F89B 20 6A F8      [ 6]   82         jsr     I2CWBYTE
   F89E B0 17         [ 4]   83         bcs     SKIP
   F8A0 20 7E F8      [ 6]   84         jsr     I2CRBYTE
   F8A3 85 03         [ 3]   85         sta     CMDBUF0
   F8A5 20 7E F8      [ 6]   86         jsr     I2CRBYTE
   F8A8 85 04         [ 3]   87         sta     CMDBUF1
   F8AA 20 7E F8      [ 6]   88         jsr     I2CRBYTE
   F8AD 85 05         [ 3]   89         sta     CMDBUF2
   F8AF 20 7E F8      [ 6]   90         jsr     I2CRBYTE
   F8B2 85 06         [ 3]   91         sta     CMDBUF3
   F8B4 4C CB F8      [ 3]   92         jmp     ENDI2C
                             93     
   F8B7                      94 SKIP:                       ; If no device present, fake an idle response
   F8B7 A9 2E         [ 2]   95         lda     #0x2e  ; '.'
   F8B9 85 03         [ 3]   96         sta     CMDBUF0
   F8BB 4C CB F8      [ 3]   97         jmp     ENDI2C
                             98 
   F8BE                      99 I2CSRESP:
   F8BE 48            [ 3]  100         pha
   F8BF 20 3A F8      [ 6]  101         jsr     I2CSTART
   F8C2 A9 10         [ 2]  102         lda     #I2CWADR
   F8C4 20 6A F8      [ 6]  103         jsr     I2CWBYTE
   F8C7 68            [ 4]  104         pla
   F8C8 20 6A F8      [ 6]  105         jsr     I2CWBYTE
   F8CB                     106 ENDI2C:
   F8CB 20 41 F8      [ 6]  107         jsr     I2CSTOP
   F8CE 60            [ 6]  108         rts
                            109 
   F8CF                     110 POLL:
   F8CF 20 96 F8      [ 6]  111         jsr     I2CRREQ
   F8D2 A5 03         [ 3]  112         lda     CMDBUF0
   F8D4 C9 52         [ 2]  113         cmp     #0x52    	; 'R' - Read memory
   F8D6 F0 0A         [ 4]  114         beq     MREAD
   F8D8 C9 57         [ 2]  115         cmp     #0x57    	; 'W' - Write memory
   F8DA F0 10         [ 4]  116         beq	MWRITE
   F8DC C9 43         [ 2]  117         cmp     #0x43    	; 'C' - Call subroutine
   F8DE F0 26         [ 4]  118         beq	REMCALL
   F8E0 18            [ 2]  119         clc
   F8E1 60            [ 6]  120         rts
                            121 
   F8E2                     122 MREAD:
   F8E2 20 F8 F8      [ 6]  123         jsr     LOADBC
   F8E5 A0 00         [ 2]  124         ldy	#0x00
   F8E7 B1 01         [ 6]  125         lda	[B],Y
   F8E9 4C 01 F9      [ 3]  126         jmp     SRESP
   F8EC                     127 MWRITE:
   F8EC 20 F8 F8      [ 6]  128         jsr     LOADBC
   F8EF A5 06         [ 3]  129         lda     CMDBUF3
   F8F1 91 01         [ 6]  130         sta     [B],Y
   F8F3 A9 57         [ 2]  131         lda     #0x57  	;'W'
   F8F5 4C 01 F9      [ 3]  132         jmp     SRESP
   F8F8                     133 LOADBC:
   F8F8 A5 05         [ 3]  134 	lda	CMDBUF2
   F8FA 85 01         [ 3]  135 	sta	B
   F8FC A5 04         [ 3]  136 	lda	CMDBUF1
   F8FE 85 02         [ 3]  137 	sta	C
   F900 60            [ 6]  138 	rts
                            139 	
   F901                     140 SRESP:
   F901 20 BE F8      [ 6]  141         jsr    I2CSRESP
   F904                     142 RHERE:
   F904 38            [ 2]  143         sec
   F905 60            [ 6]  144         rts
   F906                     145 REMCALL:
   F906 A9 F9         [ 2]  146 	lda	#>(START-1)
   F908 48            [ 3]  147         pha
   F909 A9 11         [ 2]  148         lda	#<(START-1)
   F90B 48            [ 3]  149         pha
   F90C 20 F8 F8      [ 6]  150         jsr     LOADBC
   F90F 6C 01 00      [ 5]  151         jmp     [B]
                            152         
                            153 ;;;;;;;;;;
                            154 	
   F912                     155 START:
   F912 78            [ 2]  156         sei             ; disable interrupts
   F913 A2 FF         [ 2]  157 	ldx	#SSTACK
   F915 9A            [ 2]  158 	txs		; Init stack
   F916 D8            [ 2]  159 	cld		; No Decimal
   F917 A9 00         [ 2]  160         lda     #0x00
   F919 85 00         [ 3]  161         sta     OUTBUF
   F91B 20 01 F8      [ 6]  162         jsr     ONCE
                            163 
                            164 ; Main routine
   F91E                     165 MAIN:
   F91E 20 02 F8      [ 6]  166         jsr     EVERY
   F921 20 CF F8      [ 6]  167         jsr     POLL
   F924 B0 F8         [ 4]  168         bcs     MAIN
   F926 A9 01         [ 2]  169         lda	#BIGDEL>>8
   F928 85 01         [ 3]  170         sta	B
   F92A A9 80         [ 2]  171         lda	#BIGDEL%256
   F92C 85 02         [ 3]  172         sta	C
   F92E                     173 MLOOP:
   F92E A5 02         [ 3]  174         lda	C
   F930 F0 05         [ 4]  175         beq	DECBOTH
   F932 C6 02         [ 5]  176         dec	C
   F934 4C 2E F9      [ 3]  177         jmp	MLOOP
   F937                     178 DECBOTH:
   F937 A5 01         [ 3]  179 	lda	B
   F939 F0 E3         [ 4]  180 	beq	MAIN
   F93B C6 02         [ 5]  181 	dec	C
   F93D C6 01         [ 5]  182 	dec	B
   F93F 4C 2E F9      [ 3]  183 	jmp	MLOOP
                             14 
                             15         .include "../6502/vectors.asm"
                              1 	
                              2         .bank   vectorbank   (base=VECTORS, size=0x06)
                              3         .area   vectorarea   (ABS, BANK=vectorbank)
                              4 
   FFFA 00 F8                 5 	.dw	NMI
   FFFC 12 F9                 6 	.dw	START
   FFFE 12 F9                 7 	.dw	START
