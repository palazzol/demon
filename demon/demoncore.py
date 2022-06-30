# -*- coding: utf-8 -*-
"""
Created on Tue Feb 23 23:11:53 2016

@author: Frank Palazzolo
"""

import serial
import sys

class DemonDebugger:
    def __init__(self,global_args):
        global_args.chip = global_args.chip.upper()
        if global_args.chip == 'Z80':
            global_args.mode = 8
            global_args.enable_port_io = True
        elif global_args.chip == 'CP1610':
            global_args.mode = 16
            global_args.enable_port_io = False
            global_args.rtscts = True # Required for reliable hi-speed comms on the LTO Flash
        elif global_args.chip == '6502':
            global_args.mode = 8
            global_args.enable_port_io = False
        else:
            print("Sorry, chip must be Z80, 6502, or CP1610")
            sys.exit(-1)
        self.global_args = global_args

        if self.global_args.port:
            self.ser = serial.Serial(self.global_args.port, self.global_args.rate, rtscts=self.global_args.rtscts, timeout=0.1)
        else:
            print("Port is a required field, unless using Simulation Mode")
            sys.exit(-1)

    def DoCommand(self, command):
        self.WriteCommand(command)
        return self.ReadResponse()

    def WriteCommand(self, command):
        self.ser.write(command.encode('ascii'))
        self.ser.write(b'\x0d')

    def ReadResponse(self):
        done = False
        s = ''
        while not done:
            c = self.ser.read(1)
            if c == b'':
                return ''
            if (c == b'\x0a') or (c == b'\x0d'):
                if len(s) > 0:
                    return s 
            else:
                s += c.decode('ascii')

