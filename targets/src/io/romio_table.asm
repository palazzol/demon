
; 
; For Demon Debugger Hardware - Rev D 
;
; In earlier hardware designs, I tried to capture the address bus bits on a 
; read cycle, to use to write to the Arduino.  But it turns out it is impossible
; to know exactly when to sample these address bits across all platforms, designs, and 
; clock speeds
;
; The solution I came up with was to make sure the data bus contains the same information
; as the lower address bus during these read cycles, so that I can sample the data bus just like the 
; CPU would.
;
; This block of memory, starting at 0x07c0, is filled with consecutive integers.
; When the CPU reads from a location, the data bus matches the lower bits of the address bus.  
; And the data bus read by the CPU is also written to the Arduino.
; 
; Note: Currently, only the bottom two bits are used, but reserving the memory
; this way insures that up to 5 bits could be used 
; 
        ; ROMIO READ Area - reserved
        .DB     0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
        .DB     0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff

        ; ROMIO WRITE Area - data is used
        .DB     0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
        .DB     0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f

