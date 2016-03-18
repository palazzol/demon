
///////////////////////////////////////////////////////
// "Moniker" Reference code
// by Frank Palazzolo
//
// 8-bit target debug shim, acting as
// a simplified bit-bang I2C Master
//
// For use with dedicated slave
// console interface
///////////////////////////////////////////////////////

///////////////////////////////////////////////////////
// The following calls will need to be
// implemented in a platform-specific way
///////////////////////////////////////////////////////

// Serial Adapter expected at this address
#define I2C_ADDRESS    0x08

//
// This Pseudo-I2C master interface requires three pins
//
// The SCL pin is an output, and is always driven by the master
//
// The DOUT pin is an output.  When driving SDA low, it should be driven high
// When driving SDA high or reading SDA, it should be driven low.  
// (It is meant to drive the base/gate of a pull-down transistor on SDA)
//
// The DIN put is an input.  When it is connected to SDA, and should be used 
// to read the state of the SDA pin.
// Note: DOUT is driven low in this case, or else it will always read low.

const int SCL_PIN = A5;
const int DOUT_PIN = A4;
const int DIN_PIN = A3;

void set_SCL() {
  // This call should drive the SCL pin high
  digitalWrite(SCL_PIN,1);
  I2C_delay();
}

void clear_SCL() {
  // This call should drive the SCL pin low
  digitalWrite(SCL_PIN,0);
}

void set_SDA() {
  // This call should drive the DOUT pin low
  digitalWrite(DOUT_PIN,0);
  I2C_delay();
}

void clear_SDA() {
  // This call should drive the DOUT pin high
  digitalWrite(DOUT_PIN,1);
  I2C_delay();
}

bool read_SDA() {
  // This call should read the DIN pin
  return digitalRead(DIN_PIN);
}

volatile byte g_delay = 0;
void I2C_delay() {
  // This call should delay one-half bit time
  // For 100Kbps equivalence this would be 5us,
  // but it can probably be as slow as you like 
  for(g_delay=0;g_delay<20;g_delay++);
}

byte MemoryRead(int addr) {
  // This call should read the memory location
  return 'R'; // for now
}

void MemoryWrite(int addr, byte data) {
  // This call should write to the memory location
}

byte PortRead(int addr) {
  // This call should read from the port
  return 'I'; // for now
}

void PortWrite(int addr, byte data) {
  // This call should write to the port
}

void Call(int addr) {
  // This call should call the subroutine at addr
}

///////////////////////////////////////////////////////
// Simplified Bit-bang I2C implementation
///////////////////////////////////////////////////////

void i2c_start_cond( void ) {
  // SCL is high, set SDA from 1 to 0.
  clear_SDA();
  clear_SCL();
}

void i2c_stop_cond( void ) {
  // set SDA to 0
  clear_SDA();

  // Stop bit setup time
  set_SCL();

  // SCL is high, set SDA from 0 to 1
  set_SDA();
}

// Write a bit to I2C bus
void i2c_write_bit( bool bit ) {
  if( bit ) {
    set_SDA();
  } else {
    clear_SDA();
  } 

  // Set SCL high to indicate a new valid SDA value is available
  set_SCL();

  // Clear the SCL to low in preparation for next change
  clear_SCL();
}

// Read a bit from I2C bus
bool i2c_read_bit( void ) {
  bool bit;

  // Let the slave drive data
  set_SDA();

  // Set SCL high to indicate a new valid SDA value is available
  set_SCL();

  // SCL is high, read out bit
  bit = read_SDA();

  // Set SCL low in preparation for next operation
  clear_SCL();

  return bit;
}

// Write a byte to I2C bus. Return 0 if ack by the slave.
bool i2c_write_byte( byte b ) {
  unsigned bit;

  for( bit = 0; bit < 8; bit++ ) 
  {
    i2c_write_bit( ( b & 0x80 ) != 0 );
    b <<= 1;
  }

  return i2c_read_bit();
}

// Read a byte from I2C bus
byte i2c_read_byte( bool nack ) {
  byte b = 0;
  byte bit;

  for( bit = 0; bit < 8; bit++ ) 
  {
    b = ( b << 1 ) | i2c_read_bit();
  }

  i2c_write_bit( nack );

  return b;

}

///////////////////////////////////////////////////////
// Request/Response messages to console
// Request 4 byte command,
//  will receive up to a 4 byte command
// If there is a valid command
//  Send result as 1 byte result
///////////////////////////////////////////////////////

#define I2C_READ_ADDR  ((I2C_ADDRESS<<1)+1)
#define I2C_WRITE_ADDR (I2C_ADDRESS<<1)

void i2c_read_request( byte *cmd ) {
  i2c_start_cond();
  bool nack = i2c_write_byte( I2C_READ_ADDR );
  if (nack) {
    cmd[0] = '.'; // Same result as idle
  } else {
    cmd[0] = i2c_read_byte( false );
    cmd[1] = i2c_read_byte( false );
    cmd[2] = i2c_read_byte( false );
    cmd[3] = i2c_read_byte( false );
  }
  i2c_stop_cond();
}

void i2c_send_response( byte a ) {
    i2c_start_cond();
    i2c_write_byte( I2C_WRITE_ADDR );
    i2c_write_byte( a );
    i2c_stop_cond();
}

///////////////////////////////////////////////////////
// Main Program
///////////////////////////////////////////////////////

void setup() { 
  pinMode(SCL_PIN,OUTPUT);
  pinMode(DIN_PIN,INPUT);
  pinMode(DOUT_PIN,OUTPUT);  
}

bool poll() {
  byte cmd[3];  // For the returned command
  byte data;    // For the read data value
  
  // Read Request from I2C bus.
  i2c_read_request(&cmd[0]);
    
  switch(cmd[0]) {
    case 'R':
      data = MemoryRead(cmd[1]*256+cmd[2]);
      i2c_send_response(data); // Command OK = memory value
      return true;
      break;
    case 'W':
      MemoryWrite(cmd[1]*256+cmd[2],cmd[3]);
      i2c_send_response('W'); // Command OK = 'W'
      return true;
      break;
    case 'I':
      data = PortRead(cmd[1]*256+cmd[2]);
      i2c_send_response(data); // Command OK = port value
      return true;
      break;
    case 'O':
      PortWrite(cmd[1]*256+cmd[2],cmd[3]);
      i2c_send_response('O'); // Command OK = 'O'
      return true;
      break;
    case 'C':
      // Respond first so we can end the I2C transaction, then Call
      i2c_send_response('C'); // Command OK = 'C'
      Call(cmd[1]*256+cmd[2]);
      return true;
      break;
    default:
      return false;
      break;
  }
}

void loop() {
  while (poll());
  delay(10);
}

