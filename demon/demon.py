# -*- coding: utf-8 -*-
"""
Created on Tue Feb 23 23:11:53 2016

@author: Frank Palazzolo
"""

import serial
import msvcrt

hextable = '0123456789ABCDEF'
ser = serial.Serial("COM15", 250000, timeout=1)

def MemoryRead(addr):
    cmd = 'R' + ('%04X' % addr) + '\n'
    ser.write(cmd.encode('ascii'))
    return ser.read()[0]

def MemoryWrite(addr,data):
    cmd = 'W' + ('%04X' % addr) + ('%02X' % data) + '\n'
    ser.write(cmd.encode('ascii'))
    return ser.read()[0]

def PortRead(addr):
    cmd = 'I' + ('%04X' % addr) + '\n'
    ser.write(cmd.encode('ascii'))
    return ser.read()[0]

def PortWrite(addr,data):
    cmd = 'O' + ('%04X' % addr) + ('%02X' % data) + '\n'
    ser.write(cmd.encode('ascii'))
    return ser.read()[0]

def RemoteCall(addr):
    cmd = 'C' + ('%04X' % addr) + '\n'
    ser.write(cmd.encode('ascii'))
    #return ord(ser.read())
    return

def ReadChar():
    return msvcrt.getch().decode('ascii')
    
def DisplayString(s):
    print(s, end='', flush=True)
    
def DisplayByte(i):
    print('%02X' % i, end='', flush=True)
    
def DisplayWord(i):
    print('%04X' % i, end='', flush=True)
        
def ReadInput(maxlen):
    buf = ''
    while True:
        c = ReadChar()
        if c == 9:
            if len(buf) > 0:
                buf = buf[:-1]
                DisplayString(c)
        elif (c == '\n') or (c == '\r'):
            print()
            return buf
        elif len(buf) == maxlen-1:
            buf = buf + c
            print()
            return buf
        elif len(buf) < maxlen:
            buf = buf + c
            DisplayString(c)

def DisplayBanner():
    DisplayString('DEMON - v0.82\n')

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
    checksum %= 65536
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
        DisplayByte(data)
        DisplayString(' ')
        w = ReadChar().upper()
        if (w == '\n') or (w == '\r'):
            print()
            return True
        i = hextable.find(w)
        if (i == -1):
            print()
            break
        DisplayString(w);
        data = i*16
        w = ReadChar().upper()
        i = hextable.find(w)
        if (i == -1):
            print()
            break
        DisplayString(w);
        data = data + i
        MemoryWrite(addr,data)
        addr = (addr + 1)%65536
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
    for addr in range(args[0],args[1]+1):
        MemoryWrite(addr, args[2]%256)
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
    fn = str(raw_input("Filename? "))
    fp = open(fn,'rb')
    c = fp.read(1)
    while c != '':
        MemoryWrite(addr,ord(c))
        c = fp.read(1)
        addr+=1
    return True
    
def DoCommand(s):
    if len(s) == 0:
        return False
    s = s.upper()
    cmd = s[0]
    ops = s[1:]
    if cmd in 'QDSMCFIOL':
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
        elif cmd == 'I':
            rv = DoIn(ops)
        elif cmd == 'O':
            rv = DoOut(ops)
        elif cmd == 'L':
            rv = DoLoad(ops)
        """
        elif cmd == 'S':
            rv = DoSave(ops)
        elif cmd == 'T':
            DoTest(ops):
        elif cmd == 'H':
            DoHelp(ops)

        else:
            DoError(ops)
        """
        if rv == False:
            DisplayString('HOW?\n')
    else:
        DisplayString('WHAT?\n')
    return False
    
# monitor starts here
DisplayBanner()
done = False
while not done:
    DisplayString('>')
    s = ReadInput(80)
    done = DoCommand(s)
DisplayString("BYE!\n")
