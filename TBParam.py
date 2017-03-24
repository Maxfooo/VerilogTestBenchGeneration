'''
Created on Feb 22, 2017

@author: maxr
'''


class TBParam(object):
    
    def __init__(self, name, isInput=True, isClock=False, \
                 isLastParam=False, isBus=False, busWidth=''):
        self.paramName = name
        self.setIsIO(isInput)
        self.isClock = isClock
        self.isLastParam = isLastParam
        self.isBus = isBus
        self.setBusWidth(busWidth)
        
    def setIsIO(self, isInput):
        self.isInput = isInput
        if self.isInput:
            self.dataType = 'reg'
        else:
            self.dataType = 'wire'
    
    def setIsClock(self, isClock):
        self.isClock = isClock
        # possible to have input clock
        # and an output clock, must set as 
        # input or output to determine
        # ONLY input clock will use the getClkGen()
        
    def setIsLastParam(self, isLastParam):
        self.isLastParam = isLastParam
    
    def setIsBus(self, isBus):
        self.isBus = isBus
    
    def setBusWidth(self, busStr):
        if busStr == '' or busStr == None:
            self.isBus = False
            self.busWidth = ''
        else:
            self.isBus = True
            self.busWidth = busStr
    
    def getParamName(self):
        return self.paramName
    
    def getIsIO(self):
        return self.isInput
    
    def getIsClock(self):
        return self.isClock
    
    def getIsBus(self):
        return self.isBus
    
    def printDeclaration(self):
        if self.isBus:
            return '{} {} {};\n'.format(self.dataType, self.busWidth, self.paramName)
        else:
            return '{} {};\n'.format(self.dataType, self.paramName)
    
    def printUUTParam(self):
        if self.isLastParam:
            return '\t.{}({})\n'.format(self.paramName, self.paramName) # no comma
        else:
            return '\t.{}({}),\n'.format(self.paramName, self.paramName)
    
    def printInitParam(self):
        if self.isInput:
            return '\t{} = ;\n'.format(self.paramName)
        else:
            return ''
    
    def printClkGen(self):
        if self.isInput == True and self.isClock == True:
            return 'always #(HALF_CLK_PERIOD) {} = ~{};\n'.format(self.paramName, \
                                                                  self.paramName)
        else:
            return ''
        
    def __repr__(self):
        if self.isInput:
            _io = 'Input'
        else:
            _io = 'Output'
        
        output = """ 
        Param Name: {0}
        Input/Output: {1}
        Clock: {2}
        Clock Gen: {3}
        Bus: {4}
        Bus Width: {5}
        Last Param: {6}
        Declaration: {7}
        UUT Param: {8}
        Initialize: {9}
        """.format(self.paramName, _io, self.isClock, self.printClkGen(), \
                   self.isBus, self.busWidth, self.isLastParam, self.printDeclaration(), \
                   self.printUUTParam(), self.printInitParam())
        return output
    
    
    
    