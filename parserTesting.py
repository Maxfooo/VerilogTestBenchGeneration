'''
Created on Mar 9, 2017

@author: maxr
'''
import re

INPUT_PATTERN = r'input[wirereg\s]*([\[\]\-\w\:]*)\s(\w+)'
OUTPUT_PATTERN = r'output[wirereg\s]*([\[\]\-\w\:]*)\s(\w+)'

testInput = """input wire [MESSAGE_WIDTH-1:0] data_in;
input wire [CACHE_WIDTH-1:0] eeprom_cache;"""
testInput1 = 'input wire valid;'

testOutput = "output reg [DATA_WIDTH-1:0] data_out = {DATA_WIDTH {1'b0}};"

ins = re.findall(INPUT_PATTERN, testInput)
outs = re.findall(OUTPUT_PATTERN, testOutput)

#print(ins)
#print(outs)


PARAMETER_PATTERN = r'parameter \w+\s*=\s*[\w\']+;'
test_parameter = 'parameter TEST_PARAM    = 30;\nparameter TEST_PARAM_2 = 2\'b01;'
prm = re.findall(PARAMETER_PATTERN, test_parameter)
print(prm)
