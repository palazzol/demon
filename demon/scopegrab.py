# -*- coding: utf-8 -*-
"""
Created on Tue Jun 22 20:21:25 2021

@author: frank
"""

from ds1054z import DS1054Z

# Set up comm with Rigol Scope
scope = DS1054Z('192.168.4.72')
print(scope.idn)

print("Currently displayed channels: ", str(scope.displayed_channels))

chan1 = scope.get_waveform_samples(1)
