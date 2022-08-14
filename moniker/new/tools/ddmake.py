try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib

#import pprint
import os
import sys
import glob

class DDTargetMaker:

    def __init__(self, basename, loglevel=0):
        self.basename = basename
        self.loglevel = loglevel
        self.Log(1, f'Processing target {self.basename}...')

    def Log(self, level, msg):
        if level > self.loglevel:
            return
        else:
            print(' '*(level-1)*4+msg)

    def ExtractOriginRomsize(self, elem):
        for key in elem:
            if key == 'STRTADD':
                self.origin = elem[key]
            if key == 'ROMSIZE':
                self.romsize = elem[key]

    def ExtractCPUType(self, name):
        if name == "dd/z80.def":
            self.cpu = 'Z80'
            self.assembler = 'asz80'
        elif name == "dd/6502.def":
            self.cpu = '6502'
            self.assembler = 'as6500'

    def EmitDef(self, f, elem):
        comment = elem["comment"]
        print(f"; {comment}",file=f)
        for key in elem:
            if key != 'comment':
                print(f"{key} = 0x{elem[key]:04x}",file=f)
        print(file=f)

    def EmitBankArea(self, f, elem):
        start = elem["start"]
        end = elem["end"]
        regionname = "region"+str(self.regionnum)
        print(f"        .bank   {regionname:<8}(base={start}, size={end}-{start})",file = f)
        print(f"        .area   {regionname:<8}(ABS, BANK={regionname})",file = f)
        self.regionnum += 1

    def EmitLink(self, f, name):
        print(f'        .include "../{name}"',file = f)

    def EmitInsert(self, f, name):
        print(self.target['Code'][name],file = f)

    def LoadTOML(self):
        self.Log(2, f"Loading target {self.basename}.toml...")
        with open(f'{self.basename}.toml','rb') as f:
            self.target = tomllib.load(f)
        #pprint.pp(target)
        template_name = self.target["Links"]["template"]
        self.Log(2, f"Loading template {template_name}...")
        with open("../"+template_name,'rb') as f:
            self.template = tomllib.load(f)
        #pprint.pp(template)

    def CreateTarget(self):
        self.Log(2, f"Creating {self.basename}.asm...")
        self.objpath = f'..\\output\\{self.basename}'
        if not os.path.exists(self.objpath):
            os.mkdir(self.objpath)
        with open(f"{self.objpath}\\{self.basename}.asm",'w') as f:
            for elem in self.target['Defs']:
                self.ExtractOriginRomsize(elem)
                self.EmitDef(f, elem)
            for elem in self.template['Defs']:
                self.ExtractOriginRomsize(elem)
                self.EmitDef(f, elem)
            self.regionnum = 1
            for elem in self.template['Region']:
                if 'start' in elem:
                    # Emit bank/area stuff
                    self.EmitBankArea(f, elem)
                if 'code' in elem:
                    for codeelem in elem['code']:
                        if 'link' in codeelem:
                            self.EmitLink(f, codeelem['link'])
                            self.ExtractCPUType(codeelem['link'])
                        elif 'insert' in codeelem:
                            self.EmitInsert(f, codeelem['insert'])
                print("",file=f)
    
    def BuildTarget(self):
        fullname = self.objpath+'\\'+self.basename
        self.Log(2, f'Assembling {self.basename}.asm...')
        cmd = f'..\\tools\\{self.assembler}.exe -o -p -s -l {fullname}.asm'
        #print(cmd)
        rv = os.system(cmd)
        if rv != 0:
            print("ERROR: Assembly failed.")
            return rv
        self.Log(2, f'Linking {self.basename}.s19...')
        cmd = f'..\\tools\\aslink.exe -n -m -u -s {fullname}.rel'
        #print(cmd)
        rv = os.system(cmd)
        if rv != 0:
            print("ERROR: Linking failed.")
            return rv
        self.Log(2, f'Generating {self.basename}.bin...')
        cmd = f'..\\tools\\srec2bin -q -o {self.origin:04x} -a {self.romsize:04x} -f ff {fullname}.s19 {fullname}.bin'
        #print(cmd)
        rv = os.system(cmd)
        if rv != 0:
            print("ERROR: Conversion to binary failed.")
            return rv
        self.Log(2, f'Generating {self.basename}.hex...')
        cmd = f'..\\tools\\srec_cat.exe {fullname}.bin -binary -output {fullname}.hex -Intel -address-length=2 -output_block_size=16'
        #print(cmd)
        #rv = os.system(cmd)
        if rv != 0:
            print("ERROR: Conversion to hex failed.")
            return rv
        return 0

if __name__ == "__main__":
    if len(sys.argv) > 2:
        print('Usage: ddmake.py <target>')
        os.sys.exit(-1)
    if len(sys.argv) == 1:
        files = glob.glob("*.toml")
        basenames = []
        for file in files:
            basenames.append(file[0:-5])
    else:
        basenames = [ sys.argv[1] ]
    for basename in basenames:
        t = DDTargetMaker(basename,2)
        t.LoadTOML()
        t.CreateTarget()
        rv = t.BuildTarget()
        if rv != 0:
            sys.exit(rv)
    print("Done!")

