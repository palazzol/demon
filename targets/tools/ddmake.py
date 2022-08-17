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

    def ExtractCPUType(self, name):
        if name == "core/z80.def":
            self.cpu = 'Z80'
            self.assembler = 'asz80'
        elif name == "core/6502.def":
            self.cpu = '6502'
            self.assembler = 'as6500'

    def EmitBankArea(self, f, elem):
        start = elem["start"]
        end = elem["end"]
        regionname = "region"+str(self.regionnum)
        print(f";-------{regionname:^10s}-----------------------------------------------",file = f)
        print(f"",file = f)
        print(f"        .bank   {regionname:<8}(base={start}, size={end}-{start})",file = f)
        print(f"        .area   {regionname:<8}(ABS, BANK={regionname})",file = f)
        print(f"",file = f)
        self.regionnum += 1

    def EmitLink(self, f, name):
        print(f'        .include "../{name}"',file = f)

    def EmitInsert(self, f, name):
        if ('Code' in self.target) and (name in self.target['Code']):
            print(self.target['Code'][name],file = f)
            self.Log(3,f'Using target code:   "{name}"')
            if name in self.template['Code']:
                if self.target['Code'][name] == self.template['Code'][name]:
                    print(f'Warning: Code entry "{name}" in target is identical to default in template')
            else:
                print(f'Warning: Required Code entry "{name}" found in target, but has no default in template')
        else:
            if name in self.template['Code']:
                if self.template['Code'][name] == 'reserved':
                    print(f'Error: Code entry "{name}" in template is "reserved", but no entry in target')
                    sys.exit(-1)
                print(self.template['Code'][name],file = f)
                self.Log(3,f'Using default code:  "{name}"')
            else:
                print(f'Error: Required Code entry "{name}" has no definition anywhere')
                sys.exit(-1)

    def EmitHeader(self, f):
        print(f';****************************************************************', file=f)
        print(f'; This file is auto-generated by ddmake from {self.basename}.toml', file=f)
        print(f'; *** DO NOT EDIT ***', file=f)
        print(f';****************************************************************', file=f)
        print(f'', file=f)

    def ExtractParams(self):
        # first, build up a valid list of template params
        template_param_names = []
        template_param_value = {}
        template_param_comment = {}
        if 'Param' in self.template:
            for elem in self.template['Param']:
                if 'name' not in elem:
                    print(f'Error: Template [[Param]] entry has no name element')
                    sys.exit(-1)
                else:
                    name = elem['name']
                if 'value' not in elem:
                    print(f'Error: Template [[Param]] entry "{name}" has no value element')
                    sys.exit(-1)
                else:
                    value = elem['value']
                if isinstance(value,str) and value != 'reserved':
                    print(f'Error: Template [[Param]] entry "{name}" has string value, but not "reserved"')
                    sys.exit(-1)
                if not (isinstance(value,int) or isinstance(value,str)):
                    print(f'Error: Template [[Param]] entry "{name}" has invalid value. Must be integer or "reserved"')
                    sys.exit(-1)
                comment = ''
                if 'comment' in elem:
                    comment = elem['comment']
                for e in elem:
                    if e not in ['name','value','comment']:
                        print(f'Error: Template [[Param]] entry "{name}" has extra data {e}')
                        sys.exit(-1)
                template_param_names.append(name)
                template_param_value[name] = value
                template_param_comment[name] = comment

        target_param_names = []
        target_param_value = {}
        target_param_comment = {}
        if 'Param' in self.target:
            for elem in self.target['Param']:
                if 'name' not in elem:
                    print(f'Error: Target [[Param]] entry has no name element')
                    sys.exit(-1) 
                else:
                    name = elem['name']
                if 'value' not in elem:
                    print(f'Error: Target [[Param]] entry "{name}" has no value element')
                    sys.exit(-1)
                else:
                    value = elem['value']
                if not isinstance(value,int):
                    print(f'Error: Target [[Param]] entry "{name}" has non-integer value')
                    sys.exit(-1) 
                comment = ''
                if 'comment' in elem:
                    comment = elem['comment']
                for e in elem:
                    if e not in ['name','value','comment']:
                        print(f'Error: Target [[Param]] entry "{name}" has extra data {e}')
                        sys.exit(-1)
                target_param_names.append(name)
                target_param_value[name] = value
                target_param_comment[name] = comment

        for name in target_param_names:
            if name in template_param_names:
                pass
            else:
                print(f"Error: [[Param]] entry {name} in target with no default entry in template")
                sys.exit(-1)
        self.param_names = []
        self.param_value = {}
        self.param_comment = {}
        for name in template_param_names:
            self.param_names.append(name)
            if name in target_param_names:
                if target_param_value[name] == template_param_value[name]:
                    print(f'Warning: Param {name} = 0x{target_param_value[name]:04x} in target is identical to default in template')
                self.param_value[name] = target_param_value[name]
                if target_param_comment[name] == '':
                    self.param_comment[name] = template_param_comment[name]
                else:
                    self.param_comment[name] = target_param_comment[name]
                self.Log(3, f"Using target param:  {name} = 0x{self.param_value[name]:04x}")
            else:
                if template_param_value[name] == 'reserved':
                    print(f'Error: Template [[Param]] entry "{name}" has reserved value, but no entry in Target')
                    sys.exit(-1)                    
                self.param_value[name] = template_param_value[name]
                self.param_comment[name] = template_param_comment[name]
                self.Log(3, f"Using default param: {name} = 0x{self.param_value[name]:04x}")

    def ExtractOriginAndRomsize(self):
        if 'STRTADD' in self.param_names:
            self.origin = self.param_value['STRTADD']
        else:
            print("Error: Required [[Param]] entry 'STRTADD' not found")
            sys.exit(-1)
        if 'ROMSIZE' in self.param_names:
            self.romsize = self.param_value['ROMSIZE']
        else:
            print("Error: Required [[Param]] entry 'ROMSIZE' not found")
            sys.exit(-1)

    def EmitParams(self, f):
        for name in self.param_names:
            commentstring = self.param_comment[name]
            if commentstring != '':
                comments = commentstring.split('\n')
                for comment in comments:
                    print(f"; {comment}",file=f)
            value = self.param_value[name]
            print(f"{name} = 0x{value:04x}",file=f)
            print('',file=f)

    def ValidateTarget(self):
        recognized_names = [ 'Param', 'Code', 'Template' ]
        for elem in self.target:
            if elem not in recognized_names:
                print(f'Error: Unrecognized element {elem} in target {self.basename}.toml')
                sys.exit(-1)
        if 'Template' not in self.target:
            print(f'Error: No [Template] element in target {self.basename}.toml')
            sys.exit(-1)
        if 'Param' in self.target:    
            if not isinstance(self.target['Param'],list):
                print(f'Error: Param element must be [[Param]] in target {self.basename}.toml')
                sys.exit(-1)
        if 'Code' in self.target:
            if not isinstance(self.target['Code'],dict):
                print(f'Error: Code element must be [Code] in target {self.basename}.toml')
                sys.exit(-1)
        if not isinstance(self.target['Template'],dict):
            print(f'Error: Template element must be [Template] in target {self.basename}.toml')
            sys.exit(-1)
        if 'file' not in self.target['Template']:
            print(f'Error: [Template] must contain file element in target {self.basename}.toml')
            sys.exit(-1)

    def ValidateTemplate(self, template_name):
        recognized_names = [ 'Param', 'Code', 'Region' ]
        for elem in self.template:
            if elem not in recognized_names:
                print(f'Error: Unrecognized element {elem} in template {template_name}.toml')
                sys.exit(-1)
        if 'Param' not in self.template:
            print(f'Error: No [[Param]] element in template {template_name}.toml')
            sys.exit(-1)
        if 'Region' not in self.template:
            print(f'Error: No [[Region]] element in template {template_name}.toml')
            sys.exit(-1)
        if not isinstance(self.template['Param'],list):
            print(f'Error: Param element must be [[Param]] in template {template_name}.toml')
            sys.exit(-1)
        if 'Param' in self.template:
            if not isinstance(self.template['Code'],dict):
                print(f'Error: Code element must be [Code] in template {template_name}.toml')
                sys.exit(-1)
        if not isinstance(self.template['Region'],list):
            print(f'Error: Region element must be [[Region]] in template {template_name}.toml')
            sys.exit(-1)

    def LoadTOML(self):
        self.Log(2, f"Loading target {self.basename}.toml...")
        if not os.path.exists(f'{self.basename}.toml'):
            print(f'Error: {self.basename}.toml not found')
            sys.exit(-1)            
        with open(f'{self.basename}.toml','rb') as f:
            self.target = tomllib.load(f)
        #pprint.pp(self.target)
        self.ValidateTarget()
        template_name = self.target['Template']['file']
        self.Log(2, f"Loading template {template_name}...")
        if not os.path.exists(f'..\\{template_name}'):
            print(f'Error: Referenced template file {template_name} not found')
            sys.exit(-1)
        with open("..\\"+template_name,'rb') as f:
            self.template = tomllib.load(f)
        #pprint.pp(self.template)
        self.ValidateTemplate(template_name)

    def CreateTarget(self):
        self.Log(2, f"Creating {self.basename}.asm...")
        objpath = f'..\\..\\bin'
        if not os.path.exists(objpath):
            os.mkdir(objpath)            
        self.objpath = f'{objpath}\\{self.basename}'
        if not os.path.exists(self.objpath):
            os.mkdir(self.objpath)
        with open(f"{self.objpath}\\{self.basename}.asm",'w') as f:
            self.EmitHeader(f)
            self.ExtractParams()
            self.ExtractOriginAndRomsize()
            self.EmitParams(f)
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
            if not self.cpu:
                print("ERROR: CPU type cannot be determined, please add include of <cpu>.def to template file")
                sys.exit(-1)
            
    
    def BuildTarget(self):
        fullname = self.objpath+'\\'+self.basename
        self.Log(2, f'Assembling {self.basename}.asm...')
        cmd = f'..\\..\\tools\\{self.assembler}.exe -o -p -s -l {fullname}.asm'
        #print(cmd)
        rv = os.system(cmd)
        if rv != 0:
            print("ERROR: Assembly failed.")
            return rv
        self.Log(2, f'Linking {self.basename}.s19...')
        cmd = f'..\\..\\tools\\aslink.exe -n -m -u -s {fullname}.rel'
        #print(cmd)
        rv = os.system(cmd)
        if rv != 0:
            print("ERROR: Linking failed.")
            return rv
        self.Log(2, f'Generating {self.basename}.bin...')
        cmd = f'..\\..\\tools\\srec2bin -q -o {self.origin:04x} -a {self.romsize:04x} -f ff {fullname}.s19 {fullname}.bin'
        #print(cmd)
        rv = os.system(cmd)
        if rv != 0:
            print("ERROR: Conversion to binary failed.")
            return rv
        self.Log(2, f'Generating {self.basename}.hex...')
        cmd = f'..\\..\\tools\\srec_cat.exe {fullname}.bin -binary -output {fullname}.hex -Intel -address-length=2 -output_block_size=16'
        #print(cmd)
        #rv = os.system(cmd)
        if rv != 0:
            print("ERROR: Conversion to hex failed.")
            return rv
        return 0

if __name__ == "__main__":
    if len(sys.argv) == 1 or len(sys.argv) > 3:
        print('Usage: ddmake.py <target> (loglevel)')
        os.sys.exit(-1)
    loglevel = 1
    if len(sys.argv) > 2:
        loglevel = int(sys.argv[2])
    if sys.argv[1] == 'clean':
        files = glob.glob("*.toml")
        basenames = []
        for file in files:
            basenames.append(file[0:-5])
        bindir = '..\\..\\bin'
        for basename in basenames:
            for suffix in ['lst','sym','map','hlr','rel','s19']:
                try:
                    os.remove(f'{bindir}\\{basename}\\{basename}.{suffix}')
                except:
                    pass
    elif sys.argv[1] == 'cleanall':
        files = glob.glob("*.toml")
        basenames = []
        for file in files:
            basenames.append(file[0:-5])
        bindir = '..\\..\\bin'
        for basename in basenames:
            for suffix in ['lst','sym','map','hlr','rel','s19','asm','bin','hex','rst']:
                try:
                    os.remove(f'{bindir}\\{basename}\\{basename}.{suffix}')
                except:
                    pass
    else: 
        if sys.argv[1] == 'all':
            files = glob.glob("*.toml")
            basenames = []
            for file in files:
                basenames.append(file[0:-5])
        else:
            basenames = [ sys.argv[1] ]
        for basename in basenames:
            t = DDTargetMaker(basename,loglevel)
            t.LoadTOML()
            t.CreateTarget()
            rv = t.BuildTarget()
            if rv != 0:
                sys.exit(rv)
            #rv = os.system(f'fc ..\\output\\{basename}\\{basename}.bin ..\\backup\\targets\\{basename}.bin')
            #if rv != 0:
            #    sys.exit(rv)
    print("Done!")

