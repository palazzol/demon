# -*- coding: utf-8 -*-
"""
Created on Wed Jul 22 16:35:11 2020

@author: palazzol
"""

import argparse
from demon import DemonDebugger

# Parsing the arguments
parser = argparse.ArgumentParser(description = 'Demon Debugger')
parser.add_argument('-p','--port',help='Serial Port Name',required=False)
parser.add_argument('-r','--rate',default=250000,help='Serial Port Baud Rate',required=False)
parser.add_argument('--rtscts',help='Serial Port RTS/CTS handshaking',required=False,action="store_true")
parser.add_argument('-s','--sim',help='Simulation only mode',required=False,action="store_true")
parser.add_argument('-c','--chip',default='',help='CPU architecture (Z80, 6502, 6800, or CP1610)',required=True)
global_args = parser.parse_args()

dd = DemonDebugger(global_args)
dd.RunCommandLine()