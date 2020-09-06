# -*- coding: utf-8 -*-
"""
Created on Wed Jul 22 16:19:30 2020

@author: palazzol
"""

from demon import DemonDebugger
from time import sleep

from ds1054z import DS1054Z

import json

# Set up comm with Rigol Scope
scope = DS1054Z('192.168.1.110')
print(scope.idn)
chan1 = scope.get_waveform_samples(1)

# Set up Demon Debugger
class args:
    pass

args.port = 'COM11'
args.chip = 'Z80'

# These should be defaults
args.sim = False
args.rate = 250000
args.rtscts = False

dd = DemonDebugger(args)
sleep(1)

# Load and Run Colortest program
print('Loading')
dd.Load(0xdf00,'colortest.bin')
sleep(1)
print('Calling')
dd.DoCall('DF00')
sleep(1)

# Reset color 0, gets rid of lingering colorburst
dd.DoOut('0000 00')
sleep(0.1)

"""
# Now, cycle through all colors and record 3 channels of data
data = []
for i in range(0,256):
    print('Processing color: {0:02X}'.format(i))
    dd.DoOut('0004 {0:02X}'.format(i))
    sleep(1.0)
    chan1 = scope.get_waveform_samples(1)
    chan2 = scope.get_waveform_samples(2)
    chan3 = scope.get_waveform_samples(3)
    chan4 = scope.get_waveform_samples(4)
    data.append( (chan1, chan2, chan3, chan4) )

# Dump data as a json file
fp = open('nidata.json','w')
json.dump(data, fp)
fp.close()
"""

# Now, cycle through all colors and record 3 channels of data
data = []
for i in range(0,8):
    print('Processing color: {0:02X}'.format(i))
    dd.DoOut('0004 {0:02X}'.format(i))
    sleep(1.0)
    chan1 = scope.get_waveform_samples(1)
    chan2 = scope.get_waveform_samples(2)
    chan3 = scope.get_waveform_samples(3)
    chan4 = scope.get_waveform_samples(4)
    data.append( (chan1, chan2, chan3, chan4) )

# Dump data as a json file
fp = open('lumadata.json','w')
json.dump(data, fp)
fp.close()


    
