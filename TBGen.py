'''
Created on Mar 7, 2017

@author: maxr
'''

from TBParam import TBParam

import re

MODULE_PATTERN = r'(module[\s\w\d]+\([\n\s\d\w,]+\);)'
MODULE_NAME_PATTERN = r'module\s*([\w\d]+)'

INPUT_PATTERN = r'input[wirereg\s]*([\[\]\-\w\:]*)\s(\w+)'
OUTPUT_PATTERN = r'output[wirereg\s]*([\[\]\-\w\:]*)\s(\w+)'

PARAMETER_PATTERN = r'parameter \w+\s*=\s*[\w\']+;'

CLOCK_TOKENS = ['clock', 'Clock', 'clk', 'Clk']
CLOCK_TEMPLATE = 'always #(HALF_CLK_PERIOD) {} = ~{};\n'

TEST_BENCH_TEMPLATE = """
`timescale 1ns / 1ps

module {0} ();

{1}

{2}
{3} UUT (\n{4}\n);

{5}

initial begin
{6}
end

endmodule\n"""

class TBGen(object):
    def __init__(self):
        pass
    
    def prepSimpleGen(self):
        
        self.module = re.findall(MODULE_PATTERN, self.vfile)[0].replace('\n', ' ')
        self.moduleIOs = [x.strip() for x in self.module[self.module.find('(')+1: self.module.find(')')].split(',')]
        
        self.moduleClks = []
        for ios in self.moduleIOs:
            for clkTkn in CLOCK_TOKENS:
                if clkTkn in ios:
                    self.moduleClks.append(ios)
        
    
    def prepGen(self):
        
        self.moduleInputs = re.findall(INPUT_PATTERN, self.vfile)
        self.moduleOutputs = re.findall(OUTPUT_PATTERN, self.vfile)
        self.verilogParams = re.findall(PARAMETER_PATTERN, self.vfile)
        self.verilogParams.append('parameter HALF_CLK_PERIOD = 50; // 10MHz')
        
        self.moduleParams = []
        
        for i, inputs in enumerate(self.moduleInputs):
            is_clock = False
            for clkTkn in CLOCK_TOKENS:
                if clkTkn in inputs[1]:
                    is_clock = True
                    
            tempParam = TBParam(name=inputs[1], isInput=True, \
                                isClock=is_clock, isLastParam=False, busWidth=inputs[0])
            self.moduleParams.append(tempParam)
            
            
            
        
        _lenOut = len(self.moduleOutputs)
        for i, outputs in enumerate(self.moduleOutputs):
            if i == _lenOut-1:
                tempParam = TBParam(outputs[1], False, False, True, busWidth=outputs[0])
                self.moduleParams.append(tempParam)
            else:
                tempParam = TBParam(outputs[1], False, False, False, busWidth=outputs[0])
                self.moduleParams.append(tempParam)
                
                
    
    def examineFile(self):
        self.moduleName = re.findall(MODULE_NAME_PATTERN, self.vfile)[0]
        
        ins = re.search(INPUT_PATTERN, self.vfile)
        outs = re.search(OUTPUT_PATTERN, self.vfile)
        if ins == None and outs == None:
            self.simpleGen = True
            self.prepSimpleGen()
        else:
            self.simpleGen = False
            self.prepGen()
    
    def generate(self, moduleFileName):
        
        f = open(moduleFileName, 'r')
        self.vfile = f.read()
        f.close()
        
        self.examineFile()
        
        tb_moduleName = 'tb_' + self.moduleName
        tb_fileName = tb_moduleName + '.v'
        
        tb_IODeclarations = ''
        tb_IOUUTparams = ''
        tb_inputInit = ''
        tb_clkGen = ''
        tb_vParams = ''
        
        if self.simpleGen:
            for io in self.moduleIOs:
                tb_IODeclarations = tb_IODeclarations + 'reg {};\n'.format(io)
                tb_IOUUTparams = tb_IOUUTparams + '\t.{}({}),\n'.format(io, io)
                tb_inputInit = tb_inputInit + '\t{} = ;\n'.format(io)
            
            for clks in self.moduleClks:
                tb_clkGen = tb_clkGen + CLOCK_TEMPLATE.format(clks, clks)
                
        else:
            for param in self.moduleParams:
                print(param)
                tb_IODeclarations = tb_IODeclarations + param.printDeclaration()
                tb_IOUUTparams = tb_IOUUTparams + param.printUUTParam()
                tb_inputInit = tb_inputInit + param.printInitParam()
                tb_clkGen = tb_clkGen + param.printClkGen()
        
        for vParam in self.verilogParams:
            tb_vParams = tb_vParams + vParam + '\n'
        
        f = open(tb_fileName, 'w')
        f.write(TEST_BENCH_TEMPLATE.format(tb_moduleName, \
                           tb_vParams, \
                           tb_IODeclarations, \
                           self.moduleName, \
                           tb_IOUUTparams, \
                           tb_clkGen, \
                           tb_inputInit))
        f.close()





