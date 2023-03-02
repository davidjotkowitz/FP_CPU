
#test (used for modules):
reg=[0]*32
reg2=[0]*32
reg_res = [0]*32
#reg2[31] = 1
#reg_res[1] = 1
reg_res[0] = 1
#reg_res[7] = 1
#reg2[1] = 1
'''
for ii in range(1,5):
    #reg2[ii] = 1
    reg2[ii] = 1

for ii in range(9,20):
    #reg2[ii] = 1
    reg[ii] = 1


for ii in range(2,6):
    reg2[ii] = 1
    #reg2[ii] = 1

for ii in range(9,20):
    reg2[ii] = 1
    #reg2[ii] = 1

for ii in range(1,32):
    reg_res[ii] = 1
'''

#reg_res[0] = 1

listofones1 = [6,16,19,30,31]
listofones2 = [4,5,6,18,19,20,21,23]

listofones3 = [2,3,6,7,8,17,19,22,23,24,26,27,28,30,31]
for ii in listofones1:
    reg[ii]= 1


for ii in listofones3:
    reg_res[ii]= 1

for ii in listofones2:
    reg2[ii]= 1
print('')
print('   first arg: ', reg)
print('   second arg:', reg2)
print('   result:    ', reg_res)

reg2[30] = 1

#reg2[0]=1
reg[0] = 1
reg[5] = 1
reg[6] = 1
reg[7] = 1
reg[9] = 1
reg[11] = 1
reg[12] = 1
reg[13] = 1
reg[14] = 1
reg[18] = 1
reg[19] = 1
reg[20] = 1
reg[22] = 1
reg[24] = 1
reg[30] = 1

reg2[3]=1
reg2[6]=1
reg2[8]=1
reg2[13]=1
reg2[16]=1
reg2[17]=1
reg2[18]=1
reg2[19]=1
reg2[22]=1
reg2[24]=1
reg2[25]=1
reg2[30]=1


reg[0] = 1
reg[4] = 1
reg[8] = 1
reg[13] = 1

for ii in range(22,31):
    reg[ii] = 1



reg2[1] = 1
reg2[2] = 1
reg2[5] = 1
reg2[8] = 1
reg2[15] = 1
reg2[31] = 1
#reg2[28] = 1
#reg2[29] = 1



#for ii in range(18,23):
   # reg[ii]= 1
    #reg2[ii] = 1
#for ii in range(26,30):
    #reg[ii] = 1
    #reg2[ii] = 1
#for ii in range(12, 18):
 #   reg2[ii] = 1


'''
reg=[0]*32
#print(*reversed(reg))
reg_f = int_to_float(reg,RTZ)
reg_ff = register_32_f(reg_f)
#print(reg_ff.val)
def split_to_list(word):
    return list(map(int,list(word)))
reg1 = split_to_list('01000010001110010101000111101100')
reg2 = split_to_list('01001000010110010010111011010011')
div_res, unf_res = div_reg(reg1,reg2,RTZ)


#test:
reg = [0]*32
reg[5] = 1
reg[4]=1
reg[15]=1
reg[1] = 1
reg[28]=1


#print(*reversed(reg))
print((reg))
reg_f = int_to_float(reg,RNE)
reg_ff = register_32_f(reg_f)
print(reg_ff.val)


reg2 = [0]*32
reg2[5] = 1
reg2[4]=1
reg2[16]=1
reg2[1] = 1
reg_f2 = int_to_float(reg2,RNE)
reg_ff2 = register_32_f(reg_f2)
print(reg_ff2.val)
print(compare_reg(reg_f2, reg_f2, LE))
'''
'''
reg2 = [0]*32
reg = [0]*32
def  split_to_list(word):
    return list(map(int,list(word)))
reg = split_to_list('10010110110100001000010100010010')
reg.reverse()
reg2 = split_to_list('00000001100110000000111011100001')
reg2.reverse()
reg_res = sub_reg(reg, reg2, RTZ)
##reg_res.reverse()
reg.reverse()
reg2.reverse()


print('first arg: ', reg)
print('second arg:', reg2)
print('result:    ', reg_res)
'''

'''
reg2[5] = 1
reg2[4]=1
reg2[16]=1
reg2[1] = 1
reg2[31]=1

print((reg2))
reg_f2 = int_to_float(reg2,RNE)
reg_ff2 = register_32_f(reg_f2)
print(reg_ff2.val)

sum_reg_f = sub_reg(reg_f,reg_f2,RTZ)
sum_reg_f2 = sub_reg(reg_f,reg_f2,RNE)
#print(268468288+268468256)
print(register_32_f(sum_reg_f).val)
print(register_32_f(sum_reg_f2).val)
'''

#print(*reversed(reg), sep='')

#print(halt, reg_out)
#print(halt, reg_out)
#reg_f, reg_pow, reg_out, Y_0, halt = sqrt_reg(reg_f, reg_pow, reg_out, Y_0, halt)
#print(halt, reg_out)
#reg_f, reg_pow, reg_out, Y_0, halt = sqrt_reg(reg_f, reg_pow, reg_out, Y_0, halt)
#print(halt, reg_out)
#reg_f, reg_pow, reg_out, Y_0, halt = sqrt_reg(reg_f, reg_pow, reg_out, Y_0, halt)
#print(halt, reg_out)
#reg_f, reg_pow, reg_out, Y_0, halt = sqrt_reg(reg_f, reg_pow, reg_out, Y_0, halt)
#print(halt, reg_out)
#reg_f, reg_pow, reg_out, Y_0, halt = sqrt_reg(reg_f, reg_pow, reg_out, Y_0, halt)
#print(halt, register_32_f(reg_out).val)

'''
#test
#print(*num_to_list(int(3.9),8))


reg = [0]*32
reg[5] = 1
reg[1] = 1
reg[30]=1
reg_f = int_to_float(reg)

reg_ff = register_32_f(reg_f)

reg2 = [0]*32
reg2[6] = 1
reg2[1] = 1
reg2[8]=1
reg_f2 = int_to_float(reg2)
reg_ff2 = register_32_f(reg_f2) #66
#print(reg_ff2.val)

sum_reg_f = add_reg(reg_f2, reg_f)
sum_reg_ff = register_32_f(sum_reg_f)
mul_f = mul_reg(sum_reg_f, reg_f2)[0]
mul_val = register_32_f(mul_f).val
div_f = div_reg(reg_f,mul_f)[0]
div_val = register_32_f(div_f).val
print(mul_val)
print(reg_ff.val)
print(reg_ff.val/mul_val)
print(div_val)
new_mul_f = mul_reg(div_f, reg_f2)[0]
print(div_val)
print(reg_ff2.val)

print(register_32_f(new_mul_f).val)

reg = split_to_list('11000101011111001111111001000101')
print('here' , reg)
'''