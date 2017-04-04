# -*- coding: utf-8 -*-
"""
Created on Tue Feb 23 23:11:53 2016

@author: Frank Palazzolo
"""

import serial
import argparse
import sys
import kbhit

# Parsing the arguments
parser = argparse.ArgumentParser(description = 'Demon Debugger')
parser.add_argument('-p','--port',help='Serial Port Name',required=False)
parser.add_argument('-r','--rate',help='Serial Port Baud Rate',required=False)
parser.add_argument('--rtscts',help='Serial Port RTS/CTS handshaking',required=False,action="store_true")
parser.add_argument('-s','--sim',help='Simulation only mode',required=False,action="store_true")
parser.add_argument('-c','--chip',default='Z80',help='CPU architecture (Z80 or CP1610)',required=True)
global_args = parser.parse_args()

if global_args.chip == 'Z80':
    global_args.mode = 8
    global_args.enable_port_io = True
elif global_args.chip == 'CP1610':
    global_args.mode = 16
    global_args.enable_port_io = False
else:
    print("Sorry, chip must be Z80 or CP1610")
    sys.exit(-1)
    
hextable = '0123456789ABCDEF'
            
if global_args.sim == False:
    if global_args.port and global_args.rate:
        ser = serial.Serial(global_args.port, global_args.rate, rtscts=global_args.rtscts, timeout=1)
    else:
        print("Port and Rate are required fields, unless using Simulation Mode")
        sys.exit(-1)
else:
    simram = [0] * 0x10000
            
kb = kbhit.KBHit()

def MemoryRead(addr):
    if global_args.sim:
        return simram[addr]
    cmd = 'R{0:04X}\n'.format(addr)
    ser.write(cmd.encode('ascii'))
    if global_args.mode == 16:
        rv = ser.read(4)
        v = 0
        for i in range(0,4):
            v <<= 4
            v += hextable.find(chr(rv[i]))
        return v
    else:
        return ser.read()[0]    

def MemoryWrite(addr,data):
    if global_args.sim:
        simram[addr] = data
        return ord('W')
    if global_args.mode == 16:
        cmd = 'W{0:04X}{1:04X}\n'.format(addr,data)
        ser.write(cmd.encode('ascii'))
        return ser.read()[0]
    else:
        cmd = 'W{0:04X}{1:02X}\n'.format(addr,data)
        ser.write(cmd.encode('ascii'))
        return ser.read()[0]        

def PortRead(addr):
    if global_args.sim:
        return 0xaa
    cmd = 'I{0:04X}\n'.format(addr)
    ser.write(cmd.encode('ascii'))
    return ser.read()[0]

def PortWrite(addr,data):
    if global_args.sim:
        return ord('O')
    cmd = 'I{0:04X}{1:02X}\n'.format(addr,data)
    ser.write(cmd.encode('ascii'))
    return ser.read()[0]

def RemoteCall(addr):
    if global_args.sim:
        return
    cmd = 'C{0:04X}\n'.format(addr)
    for c in cmd:
        ser.write(c.encode('ascii'))
    return ser.read()[0]
    
def ReadInput(s):
    global kb
    kb.set_normal_term()
    rv = input(s)
    kb = kbhit.KBHit()
    return rv
    
def ReadChar():
    return kb.getch()
    
def DisplayString(s):
    print(s, end='', flush=True)
    
def DisplayByte(i):
    print('{0:02X}'.format(i), end='', flush=True)
    
def DisplayWord(i):
    print('{0:04X}'.format(i), end='', flush=True)

def DisplayBanner():
    DisplayString('DEMON for '+global_args.chip+', v0.9\n')

def Parse(ops):
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
    
def DoDump(ops):
    args = Parse(ops)
    if len(args) != 2:
        return False
    if global_args.mode == 16:
        for i in range(args[0],args[1]+1,8):
            DisplayWord(i)
            DisplayString(': ')
            s = ''
            for addr in range(i,i+8):
                data = MemoryRead(addr)
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
                data = MemoryRead(addr)
                DisplayByte(data)
                DisplayString(' ')
                if (data>=32 and data <128):
                    s = s + chr(data)
                else:
                    s = s + '.'
            DisplayString(s + '\n')        
    return True

def DoChecksum(ops):
    args = Parse(ops)
    if len(args) != 2:
        return False
    checksum = 0
    for addr in range(args[0],args[1]+1):   
        checksum += MemoryRead(addr)
    checksum %= 0x10000
    DisplayWord(checksum)
    DisplayString('\n')
    return True

def DoModify(ops):
    args = Parse(ops)
    if len(args) != 1:
        return False
    addr = args[0]
    
    while(1):
        data = MemoryRead(addr)
        DisplayWord(addr)
        DisplayString(' ')
        if global_args.mode == 16:
            DisplayWord(data)
        else:
            DisplayByte(data)
        DisplayString(' ')

        data = 0
        
        if global_args.mode == 16:
            w = ReadChar().upper()
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
            
            w = ReadChar().upper()
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
            
        w = ReadChar().upper()
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
        
        w = ReadChar().upper()
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
        
        MemoryWrite(addr,data)
        addr = (addr + 1)%0x10000
        print()
    
    return True

def DoCall(ops):
    args = Parse(ops)
    if len(args) != 1:
        return False
    RemoteCall(args[0])
    return True
    
def DoFill(ops):
    args = Parse(ops)
    if len(args) != 3:
        return False
    if global_args.mode == 16:
        data = args[2]%0x10000
    else:
        data = args[2]%0x100
    for addr in range(args[0],args[1]+1):
        MemoryWrite(addr, data)
    return True

def DoIn(ops):
    args = Parse(ops)
    if len(args) != 1:
        return False
    data = PortRead(args[0])
    DisplayByte(data)
    print()
    return True
    
def DoOut(ops):
    args = Parse(ops)
    if len(args) != 2:
        return False
    PortWrite(args[0],args[1])
    return True

def DoLoad(ops):
    args = Parse(ops)
    if len(args) != 1:
        return False
    addr = args[0]
    fn = ReadInput("Filename? ")
    fp = open(fn,'rb')
    if global_args.mode == 16:
        c = fp.read(2)
        while len(c) != 0:
            MemoryWrite(addr,c[0]*0x100+c[1])
            c = fp.read(2)
            addr+=1
    else:
        c = fp.read(1)
        while len(c) != 0:
            MemoryWrite(addr,ord(c))
            c = fp.read(1)
            addr+=1
    return True

def DoWrite(ops):
    args = Parse(ops)
    if len(args) != 2:
        return False
    fn = ReadInput("Filename? ")
    fp = open(fn,'wb')
    if global_args.mode == 16:
        for i in range(args[0],args[1]+1,8):
            DisplayWord(i)
            DisplayString(': ')
            s = ''
            for addr in range(i,i+8):
                data = MemoryRead(addr)
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
                data = MemoryRead(addr)
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
    
def DoHelp(ops):
    if global_args.enable_port_io == True:
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
    
def DoCommand(s):
    if len(s) == 0:
        return False
    s = s.upper()
    cmd = s[0]
    ops = s[1:]
    if cmd in 'QDSMCFIOLHW':
        rv = False
        if cmd == 'Q':
            return True
        elif cmd == 'D':
            rv = DoDump(ops)
        elif cmd == 'S':
            rv = DoChecksum(ops)
        elif cmd == 'M':
            rv = DoModify(ops)
        elif cmd == 'C':
            rv = DoCall(ops)
        elif cmd == 'F':
            rv = DoFill(ops)
        elif global_args.enable_port_io == True:
            if cmd == 'I':
                rv = DoIn(ops)
            elif cmd == 'O':
                rv = DoOut(ops)
        elif cmd == 'L':
            rv = DoLoad(ops)
        elif cmd == 'H':
            rv = DoHelp(ops)
        elif cmd == 'W':
            rv = DoWrite(ops)
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
    
# monitor starts here
DisplayBanner()
done = False
while not done:
    s = ReadInput('>')
    done = DoCommand(s)
print("BYE!")
kb.set_normal_term()

