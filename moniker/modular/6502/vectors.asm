	
        .bank   vectorbank   (base=VECTORS, size=0x06)
        .area   vectorarea   (ABS, BANK=vectorbank)

	.dw	NMI
	.dw	START
	.dw	START
