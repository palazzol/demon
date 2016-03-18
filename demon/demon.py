# -*- coding: utf-8 -*-
"""
Created on Tue Feb 23 23:11:53 2016

@author: Frank
"""
import string
import sys

import serial
import msvcrt

hextable = '0123456789ABCDEF'
ser = serial.Serial("COM30", 250000, timeout=1)

def MemoryRead(addr):
    cmd = 'R'
    cmd = cmd + hextable[(addr>>12)&0x0f]
    cmd = cmd + hextable[(addr>>8)&0x0f]
    cmd = cmd + hextable[(addr>>4)&0x0f]
    cmd = cmd + hextable[addr&0x0f]
    cmd = cmd + '\n'
    ser.write(cmd)
    return ord(ser.read())

def MemoryWrite(addr,data):
    cmd = 'W'
    cmd = cmd + hextable[(addr>>12)&0x0f]
    cmd = cmd + hextable[(addr>>8)&0x0f]
    cmd = cmd + hextable[(addr>>4)&0x0f]
    cmd = cmd + hextable[addr&0x0f]
    cmd = cmd + hextable[(data>>4)&0x0f]
    cmd = cmd + hextable[data&0x0f]
    cmd = cmd + '\n'
    ser.write(cmd)
    return ord(ser.read())

def PortRead(addr):
    cmd = 'I'
    cmd = cmd + hextable[(addr>>12)&0x0f]
    cmd = cmd + hextable[(addr>>8)&0x0f]
    cmd = cmd + hextable[(addr>>4)&0x0f]
    cmd = cmd + hextable[addr&0x0f]
    cmd = cmd + '\n'
    ser.write(cmd)
    return ord(ser.read())

def PortWrite(addr,data):
    cmd = 'O'
    cmd = cmd + hextable[(addr>>12)&0x0f]
    cmd = cmd + hextable[(addr>>8)&0x0f]
    cmd = cmd + hextable[(addr>>4)&0x0f]
    cmd = cmd + hextable[addr&0x0f]
    cmd = cmd + hextable[(data>>4)&0x0f]
    cmd = cmd + hextable[data&0x0f]
    cmd = cmd + '\n'
    ser.write(cmd)
    return ord(ser.read())

def RemoteCall(addr):
    cmd = 'C'
    cmd = cmd + hextable[(addr>>12)&0x0f]
    cmd = cmd + hextable[(addr>>8)&0x0f]
    cmd = cmd + hextable[(addr>>4)&0x0f]
    cmd = cmd + hextable[addr&0x0f]
    cmd = cmd + '\n'
    ser.write(cmd)
    #return ord(ser.read())
    return
    
# System Specific
def DisplayChar(c):
    sys.stdout.write(c)
    sys.stdout.flush()

def ReadChar():
    c = msvcrt.getch()
    return c
    
# Generic
def DisplayString(s):
    for c in s:
        DisplayChar(c)

def DisplayNybble(u4):
    table = '0123456789ABCDEF'
    DisplayChar(table[u4])
    
def DisplayByte(i):
    DisplayNybble(i>>4)
    DisplayNybble(i%16)
    
def DisplayWord(i):
    DisplayByte(i>>8)
    DisplayByte(i%256)
        
def ReadInput(maxlen):
    buf = ''
    while True:
        c = ReadChar()
        if c == 9:
            if len(buf) > 0:
                buf = buf[:-1]
                DisplayChar(c)
        elif (c == '\n') or (c == '\r'):
            print
            return buf
        elif len(buf) == maxlen-1:
            buf = buf + c
            print
            return buf
        elif len(buf) < maxlen:
            buf = buf + c
            DisplayChar(c)

def DisplayBanner():
    DisplayString('DEMON - v0.8\n')

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
            i = string.find('0123456789ABCDEF',c)
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
            DisplayChar(' ')
            if (data>=32 and data <128):
                s = s + chr(data)
            else:
                s = s + '.'
        DisplayString(s)
        DisplayChar('\n')
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
    DisplayChar('\n')
    return True

def DoModify(ops):
    args = Parse(ops)
    if len(args) != 1:
        return False
    addr = args[0]
    
    while(1):
        data = MemoryRead(addr)
        DisplayWord(addr)
        DisplayChar(' ')
        DisplayByte(data)
        DisplayChar(' ')
        w = ReadChar().upper()
        if (w == '\n') or (w == '\r'):
            print
            return True
        i = string.find('0123456789ABCDEF',w)
        if (i == -1):
            print
            break
        DisplayChar(w);
        data = i*16
        w = ReadChar().upper()
        i = string.find('0123456789ABCDEF',w)
        if (i == -1):
            print
            break
        DisplayChar(w);
        data = data + i
        MemoryWrite(addr,data)
        addr = (addr + 1)%65536
        print
    
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
    print
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
    s = string.upper(s)
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
    DisplayChar('>')
    s = ReadInput(80)
    done = DoCommand(s)
DisplayString("BYE!\n")
