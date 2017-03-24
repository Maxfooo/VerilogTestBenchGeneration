'''
Created on Mar 9, 2017

@author: maxr
'''

from TBGen import TBGen

if __name__ == '__main__':
    moduleFileName = 'exampleModule.v'
    t = TBGen()
    t.generate(moduleFileName)