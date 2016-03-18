#include <Wire.h>

// SISSI - Simple I2C-Slave to Serial Interface
// by Frank Palazzolo

#define I2C_ADDRESS 0x08

void setup() {
  Serial.begin(250000);
  
  Wire.begin(I2C_ADDRESS);    // join i2c bus with address
  Wire.onRequest(requestEvent); // register event
  Wire.onReceive(receiveEvent); // register event
}

const byte idle[4] = { 0x2E, 0x2E, 0x2E, 0x2E };
byte xmit_buffer[4] = { 0x2E, 0x2E, 0x2E, 0x2E };

void loop() {
}

// function that executes whenever data is requested by master
// this function is registered as an event, see setup()
void requestEvent() {
  Wire.write(xmit_buffer,4);
  memcpy(xmit_buffer,idle,4);
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int how_many) {
   while (Wire.available()) {
    byte b = Wire.read();     // receive byte as a character
    Serial.write(b);
   }
}

bool got_nibble = false;
char inputString[4];
int inputStringIndex = 0;

void serialEvent() {
  while (Serial.available()) {
    byte c = (byte)Serial.read();
    if ((c == '\n') || (c == '\r')) {
      if (inputStringIndex > 0) {
        memcpy(xmit_buffer,inputString,4);
       }
      inputStringIndex = 0;
      got_nibble = false;
    } else if (inputStringIndex == 0) {
        inputString[inputStringIndex] = c;
        inputStringIndex++;
    } else if (inputStringIndex < 4) {
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

