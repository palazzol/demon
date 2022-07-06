#include "BitBang_I2C.h"
#include <Wire.h>

// SISSI - Simple I2C-Slave to Serial Interface
// by Frank Palazzolo

#define I2C_ADDRESS         0x08
#define I2C_ADDRESS_IOEXP   0x20

#define PIN_PROGRAM_nOE (2)
#define PIN_PROGRAM_WR  (3)
#define PIN_A8          (4)
#define PIN_A9          (5)
#define PIN_A10         (6)
#define PIN_nWR_ENABLE  (7)
#define PIN_IO_SCL      (8)
#define PIN_IO_SDA      (9)
#define PIN_138_ENABLE  (A3)
#define PIN_TARGET_PWR  (A7)

// Unused
#define PIN_NOBYPASS    (A0)
#define PIN_BYPASS      (A1)
#define PIN_NO_RC       (A2)

const char hex[16]="0123456789ABCDEF";

BBI2C bbi2c;

void setup() {
  // Disable Write!
  digitalWrite(PIN_nWR_ENABLE, HIGH);
  pinMode(PIN_nWR_ENABLE, OUTPUT);
  
  pinMode(PIN_PROGRAM_WR, OUTPUT);
  digitalWrite(PIN_PROGRAM_WR, HIGH);

  pinMode(PIN_PROGRAM_nOE, INPUT);
  pinMode(PIN_A8, INPUT);
  pinMode(PIN_A9, INPUT);
  pinMode(PIN_A10, INPUT);
  pinMode(PIN_IO_SCL, INPUT_PULLUP);
  pinMode(PIN_IO_SDA, INPUT_PULLUP);
  pinMode(PIN_TARGET_PWR, INPUT);

  pinMode(PIN_138_ENABLE, OUTPUT);
  digitalWrite(PIN_138_ENABLE, HIGH);

  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  
  Serial.begin(250000);

  memset(&bbi2c, 0, sizeof(bbi2c));
  bbi2c.bWire = 0; // use bit banging
  bbi2c.iSDA = PIN_IO_SDA;
  bbi2c.iSCL = PIN_IO_SCL;
  I2CInit(&bbi2c, 100000L);
  delay(100);

  // Interactive mode, I2C slave
  Wire.begin(I2C_ADDRESS);    // join i2c bus with address
  Wire.onRequest(requestEvent); // register event
  Wire.onReceive(receiveEvent); // register event
}

const byte idle[4] = { 0x2E, 0x2E, 0x2E, 0x2E };
byte xmit_buffer[4] = { 0x2E, 0x2E, 0x2E, 0x2E };

int i2c_led_counter = 0;

void DoDownload()
{
  int v = analogRead(PIN_TARGET_PWR);
  if (v > 100) {
    Serial.println(":00000001FF");
    return;
  }
  
  //Serial.println(I2CTest(&bbi2c, 0x20));

  // extra address pins driven
  pinMode(PIN_A8, OUTPUT);
  pinMode(PIN_A9, OUTPUT);
  pinMode(PIN_A10, OUTPUT);
  // data bus driven
  pinMode(PIN_PROGRAM_nOE, OUTPUT);
  digitalWrite(PIN_PROGRAM_nOE, LOW);
  
  uint8_t c[2] = { 0x01, 0x00 }; // enable address bus
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c[0], 2);
  uint8_t c1[2] = { 0x0d, 0xff }; // enable address bus pull ups
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c1[0], 2);
  uint8_t checksum = 0;
  for(int address=0;address<0x800;address++)
  {
    uint8_t c[2] = { 0x15, 0x00 }; // write to address bus
    uint8_t d;
    digitalWrite(PIN_A8, (address>>8)&1);
    digitalWrite(PIN_A9, (address>>9)&1);
    digitalWrite(PIN_A10, (address>>10)&1);
    c[1] = address&0xff;
    I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c[0], 2);
    delay(1);
    I2CReadRegister(&bbi2c, 0x20, 0x12, &d, 1); // read the data bus
    if (address % 16 == 0)
    {
      checksum = 0;
      Serial.print(":10");
      checksum += 0x10;
      Serial.print("0");
      Serial.print(hex[(address>>8)&0x0f]);
      Serial.print(hex[(address>>4)&0x0f]);
      Serial.print(hex[address&0x0f]);
      checksum += ((address>>8)&0xff);
      checksum += (address&0xff);
      Serial.print("00");
      checksum += 0x00;
    }
    Serial.write(hex[(d>>4)&0x0f]);
    Serial.write(hex[(d&0x0f)]);
    checksum += d;
    if (address % 16 == 15)
    {
      checksum = (0xff - checksum) + 1;
      Serial.write(hex[(checksum>>4)&0x0f]);
      Serial.write(hex[(checksum&0x0f)]);
      Serial.println();
    }    
  }
  Serial.println(":00000001FF");
  
  uint8_t c2[2] = { 0x0d, 0x00 }; // disable address bus pull ups
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c2[0], 2);
  uint8_t c3[2] = { 0x01, 0xff }; // disable address bus
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c3[0], 2);

  // data bus undriven
  pinMode(PIN_PROGRAM_nOE, INPUT);

  // extra address bits undriven
  pinMode(PIN_A8, INPUT);
  pinMode(PIN_A9, INPUT);
  pinMode(PIN_A10, INPUT);
}

uint8_t DecodeNibble(uint8_t c)
{
  if ((c >= '0') && (c <= '9')) {
    return c - '0';
  } else if ((c >= 'A') && (c <= 'F')) {
    return c - 'A' + 10;
  } else if ((c >= 'a') && (c <= 'f')) {
    return c - 'a' + 10;
  } else
    return 0x00;  //?
}

uint8_t DecodeByte(uint8_t ch, uint8_t cl)
{
  return (DecodeNibble(ch)<<4) | DecodeNibble(cl);
}

// return - 0=keep_going, 1=success, 2=fail
int ProcessUploadLine(char line_buffer[], int buf_length)
{
  uint8_t data_length = 0;
  uint8_t data_type = 0;
  uint8_t checksum = 0;
  uint8_t checksum2 = 0;
  uint8_t ah,al;
  int address;
    if (buf_length < 11)
      return 2;
    if (line_buffer[0] != ':')
      return 3;
    data_length = DecodeByte(line_buffer[1],line_buffer[2]);
    if (buf_length < (11+2*data_length))
      return 4;
    checksum = data_length;
    ah = DecodeByte(line_buffer[3],line_buffer[4]);
    checksum += ah;
    al = DecodeByte(line_buffer[5],line_buffer[6]);
    checksum += al;
    address = ah;
    address <<= 8;
    address |= al;
    data_type = DecodeByte(line_buffer[7],line_buffer[8]);
    //Serial.print((char)line_buffer[7]);
    //Serial.print((char)line_buffer[8]);
    //Serial.println(data_type,HEX);
    //Serial.print("data_type=");
    //Serial.println(data_type,HEX);
    checksum += data_type;
    if (address+data_length > 0x800)
      return 5;
    if (data_type > 1)
      return 6;
    int j=0;
    for(j=0;j<data_length;j++)
    {
      uint8_t data = DecodeByte(line_buffer[9+2*j],line_buffer[10+2*j]);
      checksum += data;
    }
    checksum = (checksum ^ 0xff) + 1;
    checksum2 = DecodeByte(line_buffer[9+2*j],line_buffer[10+2*j]);
    //Serial.print("checksum=");
    //Serial.println(checksum,HEX);
    //Serial.print("checksum2=");
    //Serial.println(checksum2,HEX);
    if (checksum != checksum2)
      return 7;
    if (data_type == 0) {
      // data ready to write
      digitalWrite(PIN_PROGRAM_WR, LOW);
      for(int j=0;j<data_length;j++)
      {
        uint8_t data = DecodeByte(line_buffer[9+2*j],line_buffer[10+2*j]);
        digitalWrite(PIN_A8, (address>>8)&1);
        digitalWrite(PIN_A9, (address>>9)&1);
        digitalWrite(PIN_A10, (address>>10)&1);
        uint8_t c[2] = { 0x15, 0x00 }; // write to address bus
        c[1] = address&0xff;
        I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c[0], 2);
        uint8_t d[2] = { 0x14, 0x00 }; // write to data bus
        d[1] = data;
        I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &d[0], 2);
        delay(1);
        digitalWrite(PIN_nWR_ENABLE, LOW);
        delay(1);
        digitalWrite(PIN_nWR_ENABLE, HIGH);
        //Serial.print(address,HEX);
        //Serial.print(" ");
        //Serial.println(data,HEX);
        address++;
      }
      // data not ready to write
      digitalWrite(PIN_PROGRAM_WR, HIGH);
    }
    if (data_type == 1)
    {
      return 1;
    }      
  return 0;
}

void DoUpload()
{
  int v = analogRead(PIN_TARGET_PWR);
  if (v > 100) {
    Serial.println(":00000001FF");
    return;
  }
  
  //Serial.println(I2CTest(&bbi2c, 0x20));

  // extra address pins enabled
  pinMode(PIN_A8, OUTPUT);
  pinMode(PIN_A9, OUTPUT);
  pinMode(PIN_A10, OUTPUT);

  uint8_t c[2] = { 0x01, 0x00 }; // enable address bus
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c[0], 2);
  uint8_t c1[2] = { 0x0d, 0xff }; // enable address bus pull ups
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c1[0], 2);

  uint8_t d[2] = { 0x00, 0x00 }; // enable data bus
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &d[0], 2);
  uint8_t d1[2] = { 0x0c, 0xff }; // enable data bus pull ups
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &d1[0], 2);
  
  // state - 0=keep_going, 1=success, >1=fail
  int state = 0;
  uint8_t line_buffer[256];
  uint8_t index = 0;
  uint8_t dd;
  while (state == 0)
  {
    if (Serial.available()) {
      dd = Serial.read();
      if ((dd == '\n') || (dd == '\r')) {
        if (index > 0)
        {
          state = ProcessUploadLine(line_buffer, index);
          if (state == 0)
          {
            Serial.println("*");  // ACK, more please
            //Serial.println(state);
          }
          index = 0;
        }
      }
      else if (index < 256)
      {
        line_buffer[index] = dd;
        index++;
      }
    }
  }
  //Serial.print("Upload Exit: code=");
  //Serial.println(state,HEX);

  uint8_t d2[2] = { 0x0c, 0x00 }; // disable data bus pull ups
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &d2[0], 2);
  uint8_t d3[2] = { 0x00, 0xff }; // disable data bus
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &d3[0], 2);
  
  uint8_t c2[2] = { 0x0d, 0x00 }; // disable address bus pull ups
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c2[0], 2);
  uint8_t c3[2] = { 0x01, 0xff }; // disable address bus
  I2CWrite(&bbi2c, I2C_ADDRESS_IOEXP, &c3[0], 2);

  digitalWrite(PIN_PROGRAM_WR, HIGH);

  // extra address pins undriven
  pinMode(PIN_A8, INPUT);
  pinMode(PIN_A9, INPUT);
  pinMode(PIN_A10, INPUT);
}

void loop() {
  if (i2c_led_counter == 0)
      digitalWrite(LED_BUILTIN, LOW);
  else {
      digitalWrite(LED_BUILTIN, HIGH);
      i2c_led_counter--;
  }
}

// function that executes whenever data is requested by master
// this function is registered as an event, see setup()
void requestEvent() {
  i2c_led_counter = 1000;  // This keeps the I2C LED on long enough to be seen
  Wire.write(xmit_buffer,4);
  memcpy(xmit_buffer,idle,4);
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int how_many) {
   while (Wire.available()) {
    byte b = Wire.read();     // receive byte as a character
    //Serial.write(b);
    Serial.write(hex[(b>>4)&0x0f]);
    Serial.write(hex[(b&0x0f)]);
    Serial.write('\n');
   }
}

void DoExternalFunction(uint8_t c)
{
  switch(c) {
    case 'D':
      DoDownload();
    break;
    case 'U':
      DoUpload();
    break;
    default:
       Serial.println("I");  // return to interactive mode
    break;
  }
}

bool got_nibble = false;
char inputString[4];
int inputStringIndex = 0;

// RWOIC - X
void serialEvent() {
  while (Serial.available()) {
    byte c = (byte)Serial.read();
    if ((c == '\n') || (c == '\r')) {
      if (inputStringIndex > 0) {
        if (inputString[0] == 'X')
        {
          if (inputStringIndex > 1)
          {
            DoExternalFunction(inputString[1]);
          }
          inputStringIndex = 0;
          got_nibble = false;
        }
        else
          memcpy(xmit_buffer,inputString,4);
       }
      inputStringIndex = 0;
      got_nibble = false;
    } else if (inputStringIndex == 0) {
        inputString[inputStringIndex] = c;
        inputStringIndex++;
    } else if (inputStringIndex < 4) {
      if (inputString[0] == 'X')
      {
        inputString[inputStringIndex] = c;
        inputStringIndex++;
      }
      else
      {
        byte n = 0;
        if ((c >= '0') && (c <= '9')) {
          n = c - '0';
        } else if ((c >= 'A') && (c <= 'F')) {
          n = c - 'A' + 10;
        } else if ((c >= 'a') && (c <= 'f')) {
          n = c - 'a' + 10;
        }
        if (!got_nibble) {
          inputString[inputStringIndex] = n*16;
          got_nibble = true;
        } else {
          inputString[inputStringIndex] += n;
          got_nibble = false;
          inputStringIndex++;
        }
      }
    }
  }
}
