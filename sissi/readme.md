
# Arduino USB/Serial to Pseudo-I2C Slave Adapter

The Arduino Uno adapter consists of an Arduino Uno,
and a single 2N7000 FET (Transistor)

The target device (cable) has four pins, SCL, DOUT, DIN, and GND
The 2N7000 has three pins, labelled Gate, Drain, and Source
The Arduino itself uses 3 pins, A5 (SCL), A4 (SDA), and GND

The wiring is as follows:

	TARGET      FET         ARDUINO
	--------------------------------
	SCL         N/C         A5 (SCL)
	DOUT        GATE        (N/C)
	DIN         DRAIN       A4 (SDA)
	GND         SOURCE      GND

This arrangement allows the target to provide pure inputs and outputs,
but interface directly to the I2C bus.


