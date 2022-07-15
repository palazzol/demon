
       	.db	0xaa	    ; cartridge signature
    	.db	0x55
    	
    	.dw     0x0000
    	.dw     0x0000
    	.dw     0x0000
    	.dw     0x0000
    	.dw     START
    	JP      0x0008
    	JP      0x0010
    	JP      0x0018
    	JP      0x0020
    	JP      0x0028
    	JP      0x0030
    	JP      0x0038
    	JP      0x0066
    	
    	.ascii  "BY: EVAN&FRANK/DEMON DEBUGGER/2019"
    	
START:  DI                  ; Disable interrupts - we don't handle them
        JP      INIT        ; go to initialization code

