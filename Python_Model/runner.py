import bitstring as bitstring
import numpy as numpy

import prac
##x = prac.base.newtonRaphson(1, 0.000000001, 8, 17)
##print(x)
x = prac.pipeline()

print(x.alu_m_t)
###x = __init__(x)
###x = prac.pipeline()

print(x.reg_file)

for i in range(6):
    x.clock_cycle()