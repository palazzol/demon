# demon
Debugger/Monitor for small "computers"

This software can be used to add debug capabilities to a simple "computer", even if it doesn't have a console.
It consists of three parts:

MONIKER - a small kernel of code written on the target system, supporting simple memory operations, and implementing a simple digital interface consisting of 3 pins (one input and two outputs).  This implements a simplified I2C Master.

SISSI - An arduino-based adapter - consisting of an Arduino Uno and a single transistor, implementing an I2C-slave to USB/Serial adapter

DEMON - A simple python-based debugger/monitor which serves as the UI for the system
