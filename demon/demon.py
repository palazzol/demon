# -*- coding: utf-8 -*-
"""
Created on Tue Feb 23 23:11:53 2016

@author: Frank Palazzolo
"""

import serial
import sys
import kbhit
    
hextable = '0123456789ABCDEF'

class FakeSerial:
    def __init__(self,mode):
        self.simram = [0] * 0x10000
        self.simportram = [0] * 0x10000
        self.mode = mode
    def write(self, cmd):
        self.cmd = cmd
    def read(self, response):
        if self.mode == 16:
            if self.cmd[0] == ord("R"):
                return [ord(c) for c in '{0:04X}'.format(self.simram[int(self.cmd[1:5],16)])]
            elif self.cmd[0] == ord("W"):
                self.simram[int(self.cmd[1:5],16)] = int(self.cmd[5:9],16)
                return [ord(c) for c in '{0:01X}\n'.format(self.cmd[0])]
            elif self.cmd[0] == ord("I"):
                return [ord(c) for c in '{0:04X}'.format(self.simportram[int(self.cmd[1:5],16)])]
            elif self.cmd[0] == ord("O"):
                self.simportram[int(self.cmd[1:5],16)] = int(self.cmd[5:9],16)
                return [ord(c) for c in '{0:01X}\n'.format(self.cmd[0])]
            elif self.cmd[0] == ord("C"):
                return []
        else:
            if self.cmd[0] == ord("R"):
                return [ord(c) for c in '{0:02X}\n'.format(self.simram[int(self.cmd[1:5],16)])]
            elif self.cmd[0] == ord("W"):
                self.simram[int(self.cmd[1:5],16)] = int(self.cmd[5:7],16)
                return [ord(c) for c in '{0:01X}\n'.format(self.cmd[0])]
            elif self.cmd[0] == ord("I"):
                return [ord(c) for c in '{0:02X}\n'.format(self.simportram[int(self.cmd[1:5],16)])]
            elif self.cmd[0] == ord("O"):
                self.simportram[int(self.cmd[1:5],16)] = int(self.cmd[5:7],16)
                return [ord(c) for c in '{0:01X}\n'.format(self.cmd[0])]
            elif self.cmd[0] == ord("C"):
                return []
    
def DisplayString(s):
    print(s, end='', flush=True)
    
def DisplayByte(i):
    print('{0:02X}'.format(i), end='', flush=True)
    
def DisplayWord(i):
    print('{0:04X}'.format(i), end='', flush=True)

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
        elif (global_args.chip == '6502') or (global_args.chip == '6800') or (global_args.chip == '6809') or (global_args.chip == '6811'):
            global_args.mode = 8
            global_args.enable_port_io = False
        else:
            print("Sorry, chip must be Z80, 6502, 6800, 6809, 6811, or CP1610")
            sys.exit(-1)
        self.global_args = global_args

        if self.global_args.sim == False:
            if self.global_args.port:
                self.ser = serial.Serial(self.global_args.port, self.global_args.rate, rtscts=self.global_args.rtscts, timeout=1)
            else:
                print("Port is a required field, unless using Simulation Mode")
                sys.exit(-1)
        else:
            self.ser = FakeSerial(self.global_args.mode)
            
    def RunCommandLine(self):
        self.kb = kbhit.KBHit()
        # monitor starts here
        DisplayString('DEMON for '+self.global_args.chip+', v1.0\n')
        done = False
        while not done:
            s = self.ReadInput('>')
            done = self.DoCommand(s)
        print("BYE!")
        self.kb.set_normal_term()

    def Read8Bits(self):
        rv = self.ser.read(3)
        v = 0
        for i in range(0,2):
            v <<= 4
            v += hextable.find(chr(rv[i]))
        return v

    def Read16Bits(self):
        # TBD - add cr later
        rv = self.ser.read(4)
        v = 0
        for i in range(0,4):
            v <<= 4
            v += hextable.find(chr(rv[i]))
        return v

    def MemoryRead(self,addr):
        cmd = 'R{0:04X}\n'.format(addr)
        self.ser.write(cmd.encode('ascii'))
        if self.global_args.mode == 16:
            return self.Read16Bits()
        else:
            return self.Read8Bits() 
    
    def MemoryWrite(self,addr,data):
        if self.global_args.mode == 16:
            cmd = 'W{0:04X}{1:04X}\n'.format(addr,data)
            self.ser.write(cmd.encode('ascii'))
            return self.Read8Bits()
        else:
            cmd = 'W{0:04X}{1:02X}\n'.format(addr,data)
            self.ser.write(cmd.encode('ascii'))
            return self.Read8Bits()        
    
    def PortRead(self,addr):
        cmd = 'I{0:04X}\n'.format(addr)
        self.ser.write(cmd.encode('ascii'))
        return self.Read8Bits() 
    
    def PortWrite(self,addr,data):
        cmd = 'O{0:04X}{1:02X}\n'.format(addr,data)
        self.ser.write(cmd.encode('ascii'))
        return self.Read8Bits() 
    
    def RemoteCall(self,addr):
        if self.global_args.sim:
            return
        cmd = 'C{0:04X}\n'.format(addr)
        for c in cmd:
            self.ser.write(c.encode('ascii'))
        #return ord(self.ser.read())
        return

    def ReadInput(self, s):
        self.kb.set_normal_term()
        rv = input(s)
        self.kb = kbhit.KBHit()
        print(rv)
        return rv
        
    def ReadChar(self):
        return self.kb.getch()

    def Parse(self,ops):
        current = 0
        args = []
        doing = False
        for c in ops:
            if c == ' ' or c == ',':
                if doing == True:
                    args.append(current)
                    current = 0
                    doing = False
            else:
                i = hextable.find(c)
                if c != -1:
                    if doing == False:
                        doing = True
                    current = current * 16
                    current = current + i
                else:
                    return []
        if doing == True:
            args.append(current)
        return args

    def DoDump(self,ops):
        args = self.Parse(ops)
        if len(args) != 2:
            return False
        if self.global_args.mode == 16:
            for i in range(args[0],args[1]+1,8):
                DisplayWord(i)
                DisplayString(': ')
                s = ''
                for addr in range(i,i+8):
                    data = self.MemoryRead(addr)
                    DisplayWord(data)
                    DisplayString(' ')
                    data_lsb = data&0xff
                    if (data_lsb>=32 and data_lsb <128):
                        s = s + chr(data_lsb)
                    else:
                        s = s + '.'
                DisplayString(s + '\n')
        else:
            for i in range(args[0],args[1]+1,16):
                DisplayWord(i)
                DisplayString(': ')
                s = ''
                for addr in range(i,i+16):
                    data = self.MemoryRead(addr)
                    DisplayByte(data)
                    DisplayString(' ')
                    if (data>=32 and data <128):
                        s = s + chr(data)
                    else:
                        s = s + '.'
                DisplayString(s + '\n')        
        return True

    def DoChecksum(self,ops):
        args = self.Parse(ops)
        if len(args) != 2:
            return False
        checksum = 0
        for addr in range(args[0],args[1]+1):   
            checksum += self.MemoryRead(addr)
        checksum %= 0x10000
        DisplayWord(checksum)
        DisplayString('\n')
        return True

    def DoModify(self,ops):
        args = self.Parse(ops)
        if len(args) != 1:
            return False
        addr = args[0]
        
        while(1):
            data = self.MemoryRead(addr)
            DisplayWord(addr)
            DisplayString(' ')
            if self.global_args.mode == 16:
                DisplayWord(data)
            else:
                DisplayByte(data)
            DisplayString(' ')
    
            data = 0
            
            if self.global_args.mode == 16:
                w = self.ReadChar().upper()
                if w == '\x1b':
                    print()
                    return True
                if (w == '\n') or (w == '\r'):
                    print()
                    addr = (addr + 1)%0x10000
                    continue
                i = hextable.find(w)
                if (i == -1):
                    print()
                    break
                DisplayString(w);
                data = data + i*4096
                
                w = self.ReadChar().upper()
                if w == '\x1b':
                    print()
                    return True
                if (w == '\n') or (w == '\r'):
                    print()
                    addr = (addr + 1)%0x10000
                    continue
                i = hextable.find(w)
                if (i == -1):
                    print()
                    break
                DisplayString(w);
                data = data + i*0x100
                
            w = self.ReadChar().upper()
            if w == '\x1b':
                print()
                return True
            if (w == '\n') or (w == '\r'):
                print()
                addr = (addr + 1)%0x10000
                continue
            i = hextable.find(w)
            if (i == -1):
                print()
                break
            DisplayString(w);
            data = data + i*16
            
            w = self.ReadChar().upper()
            if (w == '\n') or (w == '\r'):
                print()
                addr = (addr + 1)%0x10000
                continue
            i = hextable.find(w)
            if (i == -1):
                print()
                break
            DisplayString(w);
            data = data + i
            
            self.MemoryWrite(addr,data)
            addr = (addr + 1)%0x10000
            print()
        
        return True

    def DoCall(self,ops):
        print(ops)
        args = self.Parse(ops)
        if len(args) != 1:
            return False
        self.RemoteCall(args[0])
        return True

    def DoFill(self,ops):
        args = self.Parse(ops)
        if len(args) != 3:
            return False
        if self.global_args.mode == 16:
            data = args[2]%0x10000
        else:
            data = args[2]%0x100
        for addr in range(args[0],args[1]+1):
            self.MemoryWrite(addr, data)
        return True

    def DoIn(self,ops):
        args = self.Parse(ops)
        if len(args) != 1:
            return False
        data = self.PortRead(args[0])
        DisplayByte(data)
        print()
        return True
        
    def DoOut(self,ops):
        args = self.Parse(ops)
        if len(args) != 2:
            return False
        self.PortWrite(args[0],args[1])
        return True

    def Load(self,addr,fname):
        fp = open(fname,'rb')
        if self.global_args.mode == 16:
            c = fp.read(2)
            while len(c) != 0:
                self.MemoryWrite(addr,c[0]*0x100+c[1])
                c = fp.read(2)
                addr+=1
        else:
            c = fp.read(1)
            while len(c) != 0:
                self.MemoryWrite(addr,c[0])
                c = fp.read(1)
                addr+=1
        return True
    
    def DoLoad(self,ops):
        args = self.Parse(ops)
        if len(args) != 1:
            return False
        addr = args[0]
        fname = self.ReadInput("Filename? ")
        return self.Load(addr,fname)


    def DoWrite(self,ops):
        args = self.Parse(ops)
        if len(args) != 2:
            return False
        fn = self.ReadInput("Filename? ")
        fp = open(fn,'wb')
        if self.global_args.mode == 16:
            for i in range(args[0],args[1]+1,8):
                DisplayWord(i)
                DisplayString(': ')
                s = ''
                for addr in range(i,i+8):
                    data = self.MemoryRead(addr)
                    fp.write(data.to_bytes(2,byteorder='big'))
                    DisplayWord(data)
                    DisplayString(' ')
                    d = data&0xff
                    if (d>=32 and d<128):
                        s = s + chr(d)
                    else:
                        s = s + '.'
                DisplayString(s + '\n')
        else:
            for i in range(args[0],args[1]+1,16):
                DisplayWord(i)
                DisplayString(': ')
                s = ''
                for addr in range(i,i+16):
                    data = self.MemoryRead(addr)
                    fp.write(data.to_bytes(1,byteorder='big'))
                    DisplayByte(data)
                    DisplayString(' ')
                    if (data>=32 and data <128):
                        s = s + chr(data)
                    else:
                        s = s + '.'
                DisplayString(s + '\n')
        fp.close()
        return True

    def DoHelp(self,ops):
        if self.global_args.enable_port_io == True:
            print("""AVAILABLE COMMANDS:
            Q              - Quit
            D xxxx xxxx    - Dump Memory
            S xxxx xxxx    - Checksum Memory
            M xxxx         - Modify Memory
            C xxxx         - Call a subroutine
            F xxxx xxxx xx - Fill Memory
            I xxxx         - Input from port
            O xxxx xx      - Output to port
            L xxxx         - Load memory from file
            W xxxx xxxx    - Write file from memory
            H              - Help Menu""")
        else:
            print("""AVAILABLE COMMANDS:
            Q              - Quit
            D xxxx xxxx    - Dump Memory
            S xxxx xxxx    - Checksum Memory
            M xxxx         - Modify Memory
            C xxxx         - Call a subroutine
            F xxxx xxxx xx - Fill Memory
            L xxxx         - Load memory from file
            W xxxx xxxx    - Write file from memory
            H              - Help Menu""")        
        return True

    def DoCommand(self,s):
        if len(s) == 0:
            return False
        s = s.upper()
        cmd = s[0]
        ops = s[1:]
        if self.global_args.enable_port_io:
            cmdstring = 'QDSMCFIOLHW'
        else:
            cmdstring = 'QDSMCFLHW'
        if cmd in cmdstring:
            rv = False
            if cmd == 'Q':
                return True
            elif cmd == 'D':
                rv = self.DoDump(ops)
            elif cmd == 'S':
                rv = self.DoChecksum(ops)
            elif cmd == 'M':
                rv = self.DoModify(ops)
            elif cmd == 'C':
                rv = self.DoCall(ops)
            elif cmd == 'F':
                rv = self.DoFill(ops)
            elif cmd == 'I':
                rv = self.DoIn(ops)
            elif cmd == 'O':
                rv = self.DoOut(ops)
            elif cmd == 'L':
                rv = self.DoLoad(ops)
            elif cmd == 'H':
                rv = self.DoHelp(ops)
            elif cmd == 'W':
                rv = self.DoWrite(ops)
            """
            elif cmd == 'T':
                DoTest(ops):
            else:
                DoError(ops)
            """
            if rv == False:
                print('HOW?')
        else:
            print('WHAT?')
        return False

