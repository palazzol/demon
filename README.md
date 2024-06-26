# Demon Debugger system - 2.0 coming soon!

Debugger/Monitor for small "computers"

![RevD Photo](img/RevD.jpg "RevD Photo")

## Vintage Computer Festival Midwest 17 - 2022

- [YouTube](https://youtu.be/M9XML7viIT8)

- [Slides](doc/DD_Presentation-VCFMW_2022.pdf)

## Important Note

**We would like to port this to more systems, and/or help others fix their old things. Please let us know if you need any help getting this system going, should you choose to give it a try!**

## Newly added

* 68HC11 Reference Target - used for Chuck E Cheese Cyberamics computer

## New in version 2.0

* No EPROM programmer needed, reflash through USB serial
* New CPUs supported
  * 6800, 6809
* New targets supported
  * MicroProfessor-1 (Z80 trainer)
  * Heathkit ET-3400(A) (6800 trainer)
  * Heathkit ET-3404 (ET-3400(A) + 6809 adapter) (6809 trainer)
* GUI client
* Python API (alpha) for automating control of targets
* Modularized target code, less work for supporting new targets

## Description

Demon Debugger is a tool that can be used to repair and reverse-engineer devices with 8 and 16 bit CPUs, such as arcade machines, console games, embedded computers, single board computers, etc.  It provides a debugging console, and so is especially useful for systems that lack a working one.

It has been ported to Z80-based, 6502-based, 6800-based, 6809-based, and CP1610-based systems.  There are ports underway to other CPU architectures.

Unfortunately, Demon Debugger can't be used on a totally broken system.  The target system must have a working CPU, and at least a small amount of ROM and RAM.  However, we have found that for most hardware, it's really not too hard to get a system to this point.

## How it Works

In ROM I/O mode, The Demon Debugger board cable plugs into a socket on the target system, in place of a standard JEDEC ROM/EPROM chip.  Then, your PC can communicate with the target over serial, using a standard USB connection.

If your target system is already supported, there will be a target image already built, which you can upload onto your target.  

To support a totally new target system, a small amount of tweaking may need to be done to the assembly code for your target. Generally, if you know the memory map for your system, this is really easy to do.

## More Details

The Demon Debugger system has evolved over time.  If you have a Demon Debugger board, you can use ROM I/O mode with prebuilt target code, and get started right away, without any other tools.  If you need to support a new target, you can still use ROM I/O mode, once you build a new target code.

![Rom I/O mode diagram](img/RomIOMode.png "Rom I/O mode diagram")

If you don't have a Demon Debugger board, you can still use the Demon Debugger system in Tethered mode, provided you have a few other capabilities.  It requires only an Arduino Nano/Uno, a single transistor, and the ability to program an EPROM chip.  You need to identify points on your target which can be used (2 outputs, 1 input, and a ground), wire up your modified Arduino accordingly, and modify the communication routines in the target to use those points.  There are a few examples in the repo of doing this.

![Tethered mode diagram](img/TetheredMode.png "Tethered mode diagram")

## Currently Supported Targets

### 6502

* Generic 6502 (Works on most targets) - Atari Asteroids, VCFMW Badge!
* Atari Asteroids Arcade, tethered mode
* Atari Starship 1 Arcade

### 6800

* Heathkit ET-3400(A) (6800 trainer)

### 6809

* Heathkit ET-3404 (ET-3400(A) + 6809 adapter) (6809 trainer)
* Radio Shack Color Computer - Cartridge (6809)

### 6811

* (Chuck E. Cheese Cyberamics Computer) (6811 reference)

### Z80

* Z80 reference code (Tweakable to work on most targets)
* Sega Star Trek Arcade
* Sega Star Trek Arcade, tethered mode
* Bally Midway Gorf Arcade 
* Bally Astrocade, cartridge
* Colecovision/Bit90, cartridge
* Universal Space Raider Arcade
* MicroProfessor-1 (Z80 trainer)

### CP1610

* Mattel Intellivision - via LTO Flash cartridge*

### Other - coming soon

* Mattel Intellivision, via T-Card cartridge (CP1610 target)
* 8080/8085 targets
* Atari 2600 (6502)
* RCA1802 targets
* OS816 SBC (65C816 target)
* TI 99/4A cartridge (TMS9900 target)

## Command Line Client

![Command Line Screenshot](img/demon_screen.png "Command Line Screenshot")

## GUI Client (WIP)

![GUI Screenshot](img/DemonDebuggerGUI.png "GUI Screenshot")

## API

For now, please see the file demonapi.py

## Old Videos

Tethered Mode - [Sega Sound Board test](https://www.youtube.com/watch?v=uYlbb8uPjoU) Quality is not very good, but the Arduino module is next to the laptop

[Intellivision Demo](https://www.youtube.com/watch?v=_8YfCMpHLhY) Better quality, no Arduino needed using native serialport on the LTO Flash cart.

## 3D Rendering from KiCad

![Rev D Rendering](img/RevDRender.png "Rev D Rendering")
