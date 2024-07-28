# -*- coding: utf-8 -*-
"""
Created on Wed Jul 22 16:35:11 2020

@author: palazzol
"""

from re import X
from demoncore import DemonDebugger
import tkinter as tk
from tkinter import Tk
from tkinter import messagebox
from tkinter import ttk
from tkinter.filedialog import asksaveasfile
from tkinter.filedialog import askopenfilename
import sys
import serial
import glob

class StdoutRedirector(object):
    def __init__(self,text_widget):
        self.text_space = text_widget

    def write(self,string):
        self.text_space.insert('end', string)
        self.text_space.see('end')

    def flush(self):
        pass

class Args:
    def __init__(self,port,chip):
        self.port = port
        self.rate = 250000
        self.rtscts = False
        self.chip = chip
        self.sim = True

class DemonDebuggerGUI:
    def __init__(self):
        self.root = Tk()
        self.root.iconphoto(False, tk.PhotoImage(file='..//img//dd.png'))
        portlist = self.availableSerialPorts()
        if len(portlist) == 0:
            self.root.overrideredirect(1)
            self.root.withdraw()
            messagebox.showerror(title='Error',message='No Available Serial Ports')
            exit(0)
        elif len(portlist) == 1:
            self.launchMainGUI(portlist[0], False)
        else:
            portlabel=ttk.Label(self.root, text='Choose a port:')
            portlabel.pack(fill=tk.X)
            for port in portlist:
                portbutton = ttk.Button(self.root, text=port, command=lambda port=port: self.launchMainGUI(port, True))
                portbutton.pack(fill=tk.X)
            self.root.mainloop()

    def launchMainGUI(self, port, newroot):    
        if newroot:
            self.root.destroy()
            self.root = Tk()
        self.root.title('Demon Debugger 2.0 on '+port)
        self.style = ttk.Style()
        self.root.iconphoto(False, tk.PhotoImage(file='..//img//dd.png'))

        self.menubar = tk.Menu(self.root)
        self.filemenu = tk.Menu(self.menubar, tearoff=0)
        self.filemenu.add_command(label='Download from 28C16', command=self.Download)
        self.filemenu.add_command(label='Upload to 28C16', command=self.Upload)
        self.filemenu.add_separator()
        self.filemenu.add_command(label='Quit', command=self.root.quit)
        self.menubar.add_cascade(label="File", menu=self.filemenu)

        self.root.config(menu=self.menubar)

        self.console = ttk.Frame(self.root,width=600,height=600)
        self.console.pack(fill='both', expand=True)
        # ensure a consistent gui size
        self.console.grid_propagate(False)
        self.console.grid_rowconfigure(0,weight=1)
        self.console.grid_columnconfigure(0,weight=1)
        
        self.text = tk.Text(self.console, borderwidth=3, relief="sunken")
        self.text.config(font=("consolas",14),bg='darkblue',fg='yellow',blockcursor=True,insertbackground='yellow')
        #self.text.config(font=("consolas",14))
        self.text.grid(row=0,column=0,sticky="nsew",padx=2,pady=2)
        
        self.scroll = ttk.Scrollbar(self.console, command=self.text.yview)
        self.scroll.grid(row=0,column=1,sticky="nsew")
        self.text['yscrollcommand'] = self.scroll.set

        self.text.bind("<KeyPress>", self.OnKeyPress)

        #self.xscrollbar = tk.Scrollbar(self.console, orient=tk.HORIZONTAL)
        #self.xscrollbar.grid(row=1, column=0, sticky=tk.E+tk.W)

        #self.xscrollbar.config(command=self.text.xview)

        self.statusbar = tk.Label(self.root, text="Status Bar…", bd=1, relief=tk.SUNKEN, anchor=tk.W)
        self.statusbar.pack(side=tk.BOTTOM, fill=tk.X)

        #self.text.tag_config("datetime", foreground="blue", underline=1)
        #self.text.tag_config("HIDE", elide=False)
        
        sys.stdout = StdoutRedirector(self.text)

        self.root.after_idle(self.SerialPolling)

        args = Args(port, 'Z80')
        self.dd = DemonDebugger(args)
        self.command = ''

        self.mode = 0  # interactive commands

        self.text.focus_force()
        print('Demon Debugger 2.0 Console')
        print('>',end='')
        self.root.mainloop()

    def OnKeyPress(self,key):
        # Handle backspaces
        if key.char == chr(8):
            if len(self.command) > 0:
                self.command = self.command[0:-1]
        # Handle Enter
        elif key.char == '\r':
            if (len(self.command) > 1) and (self.command[0:2]) == 'XD':
                print('\nDownload In Progress...')
                response = self.dd.DoCommand(self.command)
                self.mode = 1
            else:
                response = self.dd.DoCommand(self.command)
                print('\n>',end='')
                return "break"
            self.command = ''
            
        # Handle everything else in range
        else:
            if key.keycode > 32 and key.keycode < 128:
                self.command += key.char

    def ProcessDownloadResponse(self, response):
        self.downloadfile.write(response)
        self.downloadfile.write('\n')
        print(response)
        if (len(response) >= 11) and (response[7:9] == '01'):
            self.downloadfile.close()

    def ProcessUploadResponse(self, response):
        if response[0] == '*':
            x = self.uploadfile.readline()
            print(x[0:-1])
            self.dd.WriteCommand(x)
            if (len(x) >= 11) and (x[7:9] == '01'):
                print('Upload Complete')
                self.mode = 0
                self.statusbar.config(text='Upload Complete')   
                self.uploadfile.close()
            else:
                y = int(x[3:7],16)/2048.0*100.0
                self.statusbar.config(text='Upload {:2.0f}% Complete'.format(y))    

    def Download(self):
        self.downloadfile=asksaveasfile(mode='w',defaultextension=".hex")
        if self.downloadfile:
            print('Download In Progress...')
            response = self.dd.DoCommand('XD')
            self.ProcessDownloadResponse(response)
            self.mode = 1

    def Upload(self):
        self.uploadfilename=askopenfilename(defaultextension=".hex")
        if self.uploadfilename != '':
            self.uploadfile = open(self.uploadfilename, 'r')
            response = self.dd.DoCommand('XU')
            x = self.uploadfile.readline()
            print(x[0:-1])
            response = self.dd.DoCommand(x)
            self.ProcessUploadResponse(response)
            self.mode = 2

    def SerialPolling(self):
        if self.mode == 0:
            response = self.dd.DoCommand('R0000')
            if response == '':
                self.statusbar.config(text="Adapter connected - Target not responding", bg='yellow')
            else:
                self.statusbar.config(text="Adapter connected - Target connected", bg='green')
            self.root.after(1000,self.SerialPolling)
        if self.mode == 1:
            response = self.dd.ReadResponse()
            if response == '':
                print('Download Terminated Unexpectedly')
                self.mode = 0
            elif (len(response) >= 11) and (response[7:9] == '01'):
                self.ProcessDownloadResponse(response)
                print('Download Complete')
                self.statusbar.config(text='Download Complete')
                self.mode = 0
            else:
                if len(response) >= 11:
                    self.ProcessDownloadResponse(response)
                    x = int(response[3:7],16)/2048.0*100.0
                    self.statusbar.config(text='Download {:2.0f}% Complete'.format(x))
            self.root.after(1,self.SerialPolling)
        if self.mode == 2:
            response = self.dd.ReadResponse()
            if response == '':
                print('Upload Terminated Unexpectedly')
                self.mode = 0
            else:
                self.ProcessUploadResponse(response)
            self.root.after(1,self.SerialPolling)

    def availableSerialPorts(self):
        """ Lists serial port names
    
            :raises EnvironmentError:
                On unsupported or unknown platforms
            :returns:
                A list of the serial ports available on the system
        """
        if sys.platform.startswith('win'):
            ports = ['COM%s' % (i + 1) for i in range(256)]
        elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
            # this excludes your current terminal "/dev/tty"
            ports = glob.glob('/dev/tty[A-Za-z]*')
        elif sys.platform.startswith('darwin'):
            ports = glob.glob('/dev/tty.*')
        else:
            raise EnvironmentError('Unsupported platform')
        result = []
        for port in ports:
            try:
                s = serial.Serial(port)
                s.close()
                result.append(port)
            except (OSError, serial.SerialException):
                pass
        return result 

ddgui = DemonDebuggerGUI()

"""
# Parsing the arguments
parser = argparse.ArgumentParser(description = 'Demon Debugger')
parser.add_argument('-p','--port',help='Serial Port Name',required=False)
parser.add_argument('-r','--rate',default=250000,help='Serial Port Baud Rate',required=False)
parser.add_argument('--rtscts',help='Serial Port RTS/CTS handshaking',required=False,action="store_true")
parser.add_argument('-s','--sim',help='Simulation only mode',required=False,action="store_true")
parser.add_argument('-c','--chip',default='',help='CPU architecture (Z80, 6502, 6800, 6809, 6811, or CP1610)',required=True)
global_args = parser.parse_args()

dd = DemonDebugger(global_args)
dd.RunCommandLine()
"""
