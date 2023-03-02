import arith
from bitstring import BitArray

# global variables of the simulation
RV_version = 32
inst_version = 32
#data_version = 32 float or double. unused

LW_mux = 1
ARITH_mux = 2
close_dmem_mux = 0
load_mux = 1
store_mux = 2

# FP registers:

class fcsr:
    def __init__(self,data):
        self.NX = data[0]
        self.UF = data[1]
        self.OF = data[2]
        self.DZ = data[3]
        self.NV = data[4]
        self.RM = data[5:7]

# full register file:
reg_file = []
if RV_version == 32:
    for i in range(32):
        reg_file.append([0] * 32)
elif RV_version == 64:
    for i in range(32):
        reg_file.append([0] * 64)
reg_file.append(fcsr([0] * 32))  #the 32th one is the fcsr

#Convertin DYN_RM to be RTZ:
reg_file[32].RM = arith.RTZ
# instruction break-down:
class inst_line:
    def __init__(self, data): #for us, every code is backwards
        self.opcode = data[0:7]
        self.rd = data[7:12]
        self.width = data[12:15]
        self.rs1 = data[15:20]
        self.imm11_0 = data[20:32]
        self.imm4_0 = data[7:12]
        self.rs2 = data[20:25]
        self.imm11_5 = data[25:32]
        self.rm = data[12:15]
        self.fmt = data[25:27]
        self.func5 = data[27:32]
        self.rs3 = data[27:32]
        self.func7 = data[25:32] #we will disregard the fmt, and trunciate it with the opcode
        self.data = data[0:32]

class globs:
    #opcode
    LOAD_FP = list(reversed([0,0,0,0,1,1,1]))  #we will use this to load ints also
    STORE_FP = list(reversed([0,1,0,0,1,1,1]))
    OP_FP = list(reversed([1,0,1,0,0,1,1]))

    '''
    FNMADD = [1,0,0,1,1,1,1]
    FNMSUB = [1,0,0,1,0,1,1]
    FMADD = [1,0,0,0,0,1,1]
    FMSUB = [1,0,0,0,1,1,1]
    '''

    #fmt:
    S = [0,0]
    D = list(reversed([0,1]))
    Q = [1,1]

    #funct7 (func5+ fmt(00- for 32 bit)):
    FADD = [0,0,0,0,0,0,0]
    FSUB = list(reversed([0,0,0,0,1,0,0]))
    FMUL = list(reversed([0,0,0,1,0,0,0]))
    FDIV = list(reversed([0,0,0,1,1,0,0]))
    FMM = list(reversed([0,0,1,0,1,0,0]))
    FCMP = list(reversed([1,0,1,0,0,0,0]))
    FSQRT = list(reversed([0,1,0,1,1,0,0]))
    FCLASS = [1,1,1,0,0,0,0]
    FSGNJ = [0,0,1,0,0,0,0]
    FCVT_I_F = list(reversed([1,1,0,1,0,0,0])) #these are just for 32 bits
    FCVT_F_I = list(reversed([1,1,0,0,0,0,0]))


    #rm:

    RNE = [0,0,0]
    RTZ = [0,0,1]

    #101, 110 invalid
    EQ = [0,1,0]
    LT = list(reversed([0,0,1]))
    LE = [0,0,0]
    DYN_RM = [1,1,1]
def num_to_list(int_, len): #returns an itirable
    if ( int_< 0 ):
        return reversed(list(map(int, list(BitArray(int=int_, length=len).bin))))
    else:
        return reversed(list(map(int, list(BitArray(uint=int_, length=len).bin))))

def num_to_reg(int_):
    ret = []
    ret[0:5] = num_to_list(int_, 5)
    return ret

def split_to_list(word):
    return list(map(int,list(word)))
#initiation:

#load Imem (instructions):

IMEM_minus = [
inst_line([*globs.LOAD_FP,  *num_to_reg(0),   0,0,0,  *num_to_reg(10),  *list(num_to_list(2, 11))]),
#load, rd(r1), width(undetermined), base(starts with 0), offset (keep zero always)
inst_line([*globs.LOAD_FP,  *num_to_reg(1),   0,0,0,  *num_to_reg(10),  *list(num_to_list(0, 11))]),
#load, rd(r6), width(undetermined), base(starts with 0), offset
inst_line([*globs.LOAD_FP,  *num_to_reg(4),   0,0,0,  *num_to_reg(10),  *list(num_to_list(1, 11))]),

inst_line([*globs.OP_FP, *num_to_reg(0),  *globs.DYN_RM,  *num_to_reg(0),    0,0,0,0,0,  *globs.FCVT_I_F]),
inst_line([*globs.OP_FP, *num_to_reg(1),  *globs.DYN_RM,  *num_to_reg(1),    0,0,0,0,0,  *globs.FCVT_I_F]),
inst_line([*globs.OP_FP, *num_to_reg(4),  *globs.DYN_RM,  *num_to_reg(4),    0,0,0,0,0,  *globs.FCVT_I_F]),

# op-fp, rd(r5),  rm, rs1(FP1), rs2(FP2), FDIV
inst_line([*globs.OP_FP, *num_to_reg(1), *globs.DYN_RM, *num_to_reg(4), *num_to_reg(1), *globs.FDIV]),
 #now we have the proper val in R1

# op-fp, rd(r1),  rm, rs1(FP1), rs2(FP2), FADD --adding zero
inst_line([*globs.OP_FP, *num_to_reg(2), *globs.DYN_RM, *num_to_reg(0), *num_to_reg(1), *globs.FADD]),




    #op-fp, rd(r0),  rm, rs1(FP1), rs2(FP2), FMUL- here we show a bypassing(1 over)
    *[
    # op-fp, rd(r1),  rm, rs1(FP1), rs2(FP2), FADD --adding zero
    inst_line([*globs.OP_FP, *num_to_reg(4), *globs.DYN_RM, *num_to_reg(4), *num_to_reg(2), *globs.FSUB]),

    #op-fp, rd(r0),  rm, rs1(FP1), rs2(FP2), FMUL- here we show a bypassing(1 over)
    inst_line([*globs.OP_FP,  *num_to_reg(2),  *globs.DYN_RM,  *num_to_reg(2),    *num_to_reg(1),  *globs.FMUL]),

    # op-fp, rd(r1),  rm, rs1(FP1), rs2(FP2), FADD --adding zero
    inst_line([*globs.OP_FP, *num_to_reg(4), *globs.DYN_RM, *num_to_reg(4), *num_to_reg(2), *globs.FADD]),

     # op-fp, rd(r0),  rm, rs1(FP1), rs2(FP2), FMUL- here we show a bypassing(1 over)
     inst_line([*globs.OP_FP, *num_to_reg(2), *globs.DYN_RM, *num_to_reg(2), *num_to_reg(1), *globs.FMUL]),
    ] *20
]
IMEM_sqrt = [
inst_line([*globs.LOAD_FP,  *num_to_reg(0),   0,0,0,  *num_to_reg(10),  *list(num_to_list(2, 11))]),
#load, rd(r1), width(undetermined), base(starts with 0), offset (keep zero always)
inst_line([*globs.LOAD_FP,  *num_to_reg(1),   0,0,0,  *num_to_reg(10),  *list(num_to_list(0, 11))]),
#load, rd(r6), width(undetermined), base(starts with 0), offset
inst_line([*globs.LOAD_FP,  *num_to_reg(4),   0,0,0,  *num_to_reg(10),  *list(num_to_list(1, 11))]),

inst_line([*globs.OP_FP, *num_to_reg(0),  *globs.DYN_RM,  *num_to_reg(0),    0,0,0,0,0,  *globs.FCVT_I_F]),
inst_line([*globs.OP_FP, *num_to_reg(1),  *globs.DYN_RM,  *num_to_reg(1),    0,0,0,0,0,  *globs.FCVT_I_F]),
inst_line([*globs.OP_FP, *num_to_reg(4),  *globs.DYN_RM,  *num_to_reg(4),    0,0,0,0,0,  *globs.FCVT_I_F]),

# op-fp, rd(r5),  rm, rs1(FP1), rs2(FP2), FDIV
inst_line([*globs.OP_FP, *num_to_reg(1), *globs.DYN_RM, *num_to_reg(4), *num_to_reg(1), *globs.FDIV]),
 #now we have the proper val in R1

# op-fp, rd(r1),  rm, rs1(FP1), rs2(FP2), FADD --adding zero
inst_line([*globs.OP_FP, *num_to_reg(2), *globs.DYN_RM, *num_to_reg(0), *num_to_reg(1), *globs.FADD]),




    #op-fp, rd(r0),  rm, rs1(FP1), rs2(FP2), FMUL- here we show a bypassing(1 over)
    *[
    #op-fp, rd(r3),  rm, rs, 00000, FSQRT- here we show a bypassing(1 over)- sqrt on first float
    inst_line([*globs.OP_FP,  *num_to_reg(3),  *globs.DYN_RM,  *num_to_reg(2),    0,0,0,0,0,  *globs.FSQRT]),

    #op-fp, rd(r0),  rm, rs1(FP1), rs2(FP2), FMUL- here we show a bypassing(1 over)
    inst_line([*globs.OP_FP,  *num_to_reg(2),  *globs.DYN_RM,  *num_to_reg(2),    *num_to_reg(1),  *globs.FMUL]),

    # op-fp, rd(r1),  rm, rs1(FP1), rs2(FP2), FADD --adding zero
    inst_line([*globs.OP_FP, *num_to_reg(4), *globs.DYN_RM, *num_to_reg(4), *num_to_reg(3), *globs.FADD])
    ] *20
]

IMEM_exp = [

    #R1 gets X, R2-R5 get the value 1
#load, rd(r1), width(undetermined), base(starts with 0), offset (keep zero always)
inst_line([*globs.LOAD_FP,  *num_to_reg(1),   0,0,0,  *num_to_reg(10),  *list(num_to_list(0, 11))]),

#load, rd(r2), width(undetermined), base(starts with 0), offset
inst_line([*globs.LOAD_FP,  *num_to_reg(2),   0,0,0,  *num_to_reg(10),  *list(num_to_list(1, 11))]),

#load, rd(r3), width(undetermined), base(starts with 0), offset
inst_line([*globs.LOAD_FP,  *num_to_reg(3),   0,0,0,  *num_to_reg(10),  *list(num_to_list(1, 11))]),

#load, rd(r4), width(undetermined), base(starts with 0), offset
inst_line([*globs.LOAD_FP,  *num_to_reg(4),   0,0,0,  *num_to_reg(10),  *list(num_to_list(1, 11))]),

#load, rd(r5), width(undetermined), base(starts with 0), offset
inst_line([*globs.LOAD_FP,  *num_to_reg(5),   0,0,0,  *num_to_reg(10),  *list(num_to_list(1, 11))]),



#op-fp, rd(r2),  rm,  rs, W/L (for us, word), fmt, FCVT.S.W (int to fp). changing first int to float- here we show a bypassing(2 over)
inst_line([*globs.OP_FP, *num_to_reg(1),  *globs.DYN_RM,  *num_to_reg(1),    0,0,0,0,0,  *globs.FCVT_I_F]),
inst_line([*globs.OP_FP, *num_to_reg(2),  *globs.DYN_RM,  *num_to_reg(2),    0,0,0,0,0,  *globs.FCVT_I_F]),
inst_line([*globs.OP_FP, *num_to_reg(3),  *globs.DYN_RM,  *num_to_reg(3),    0,0,0,0,0,  *globs.FCVT_I_F]),
inst_line([*globs.OP_FP, *num_to_reg(4),  *globs.DYN_RM,  *num_to_reg(4),    0,0,0,0,0,  *globs.FCVT_I_F]),
inst_line([*globs.OP_FP, *num_to_reg(5),  *globs.DYN_RM,  *num_to_reg(5),    0,0,0,0,0,  *globs.FCVT_I_F]),


    #op-fp, rd(r0),  rm, rs1(FP1), rs2(FP2), FMUL- here we show a bypassing(1 over)
    *[inst_line([*globs.OP_FP,  *num_to_reg(2),  *globs.DYN_RM,  *num_to_reg(2),    *num_to_reg(1),  *globs.FMUL]),

    #op-fp, rd(r5),  rm, rs1(FP1), rs2(FP2), FDIV
    inst_line([*globs.OP_FP,  *num_to_reg(2),  *globs.DYN_RM,  *num_to_reg(2),    *num_to_reg(3),  *globs.FDIV]),

    #op-fp, rd(r1),  rm, rs1(FP1), rs2(FP2), FADD
    inst_line([*globs.OP_FP,  *num_to_reg(4),  *globs.DYN_RM,  *num_to_reg(2),   *num_to_reg(4),  *globs.FADD]),

    # op-fp, rd(r1),  rm, rs1(FP1), rs2(FP2), FADD
    inst_line([*globs.OP_FP, *num_to_reg(3), *globs.DYN_RM, *num_to_reg(3), *num_to_reg(5), *globs.FADD])] *20
]


IMEM_gen =[

inst_line([*globs.LOAD_FP,  *num_to_reg(0) ,   0,1,0,  *num_to_reg(0), *list(num_to_list(0, 11))]),

#load, rd(r1), width(undetermined), base(starts with 0), offset (from r1 addr to r1) -loading second int
inst_line([*globs.LOAD_FP,  *num_to_reg(1),   0,0,0,  *num_to_reg(1),  *list(num_to_list(1, 11))]),

#op-fp, rd(r2),  rm,  rs, W/L (for us, word), fmt, FCVT.S.W (int to fp). changing first int to float- here we show a bypassing(2 over)
inst_line([*globs.OP_FP, *num_to_reg(2),  *globs.DYN_RM,  *num_to_reg(0),    0,0,0,0,0,  *globs.FCVT_I_F]),

#op-fp, rd(r3),  rm, rs, 00000, FSQRT- here we show a bypassing(1 over)- sqrt on first float
inst_line([*globs.OP_FP,  *num_to_reg(3),  *globs.DYN_RM,  *num_to_reg(2),    0,0,0,0,0,  *globs.FSQRT]),

#op-fp, rd(r4),  rm,  rs, W/L (for us, word), fmt, FCVT.S.W (int to fp). changing second int to float- here we show a bypassing(3 over. i think)
inst_line([*globs.OP_FP,  *num_to_reg(4),  *globs.DYN_RM,  *num_to_reg(1),    0,0,0,0,0,  *globs.FCVT_I_F]),

#op-fp, rd(r0),  rm, rs1(FP1), rs2(FP2), FMUL- here we show a bypassing(1 over)
inst_line([*globs.OP_FP,  *num_to_reg(0),  *globs.DYN_RM,  *num_to_reg(2),    *num_to_reg(4),  *globs.FMUL]),

#op-fp, rd(r1),  rm, rs1(FP1), rs2(FP2), FADD
inst_line([*globs.OP_FP,  *num_to_reg(1),  *globs.DYN_RM,  *num_to_reg(2),   *num_to_reg(4),  *globs.FADD]),

#op-fp, rd(r5),  rm, rs1(FP1), rs2(FP2), FDIV
inst_line([*globs.OP_FP,  *num_to_reg(5),  *globs.DYN_RM,  *num_to_reg(2),    *num_to_reg(4),  *globs.FDIV]),

#load, offset, width, base(starts with 0), rs, offset - storing sqrt FP1 into where int2 was. (check that the imm line up)
inst_line([ *globs.STORE_FP,  1,0,0,0,0,   0,1,0,  0,0,1,1,0,  0,0,0,1,1,   0,0,0,0,0,0]),

inst_line([*globs.OP_FP,  *num_to_reg(10),  *globs.EQ,  *num_to_reg(1),    *num_to_reg(1),  *globs.FCMP]),


#NOPs
inst_line([0]*32),
inst_line([0]*32),
inst_line([0]*32),
inst_line([0]*32),
inst_line([0]*32)]

IMEM_alu = [
#load, rd(r1), width(undetermined), base(starts with 0), offset (keep zero always)
inst_line([*globs.LOAD_FP,  *num_to_reg(1),   0,0,0,  *num_to_reg(10),  *list(num_to_list(0, 11))]),

#load, rd(r2), width(undetermined), base(starts with 0), offset
inst_line([*globs.LOAD_FP,  *num_to_reg(2),   0,0,0,  *num_to_reg(10),  *list(num_to_list(1, 11))]),
inst_line([0]*32),
inst_line([0]*32),
inst_line([0]*32),
inst_line([0]*32),
inst_line([0]*32),

#op-fp, rd(r1),  rm, rs1(FP1), rs2(FP2), FADD
inst_line([*globs.OP_FP,  *num_to_reg(3),  *globs.DYN_RM,  *num_to_reg(1),   *num_to_reg(2),  *globs.FADD]),

inst_line([*globs.OP_FP,  *num_to_reg(3),  *globs.DYN_RM,  *num_to_reg(1),   *num_to_reg(2),  *globs.FSUB]),

inst_line([*globs.OP_FP,  *num_to_reg(3),  *globs.DYN_RM,  *num_to_reg(1),   *num_to_reg(2),  *globs.FMUL]),

inst_line([*globs.OP_FP,  *num_to_reg(3),  *globs.DYN_RM,  *num_to_reg(1),   *num_to_reg(2),  *globs.FDIV]),

    # op-fp, rd(r3),  rm, rs, 00000, FSQRT- here we show a bypassing(1 over)- sqrt on first float
inst_line([*globs.OP_FP,  *num_to_reg(3),  *globs.DYN_RM,  *num_to_reg(1),    0,0,0,0,0,  *globs.FSQRT]),

inst_line([*globs.OP_FP,  *num_to_reg(3),  *globs.DYN_RM,  *num_to_reg(1),   *num_to_reg(2),  *globs.FCMP]),

inst_line([0]*32),
inst_line([0]*32),
inst_line([0]*32),
inst_line([0]*32),
inst_line([0]*32)
]
DMEM_alu = [list(reversed(split_to_list('01001010101100100010100100011111'))), list(reversed(split_to_list('11000100000011110001101011110010')))]
#load memory (storage):
DMEM_gen = [list(num_to_list(30004,32)),list(num_to_list(15,32))] #random numbers
DMEM_exp = [list(num_to_list(1,32)),list(num_to_list(1,32))] ##change 1st arg for different results
DMEM_sqrt = [list(num_to_list(4,32)),list(num_to_list(1,32)), list(num_to_list(0,32))] #change 1st arg for different results- 1/arg
DMEM_minus = [list(num_to_list(4,32)),list(num_to_list(1,32)), list(num_to_list(0,32))] #change 1st arg for different results- 1/arg
# first is the num, second is the "1" thirs is "0"

#Change these for correct test
IMEM = IMEM_alu
DMEM = DMEM_alu

for i in range(7,14):
    print("".join([str(x) for x in reversed(IMEM[i].data)]))


'''
print("".join([str(x) for x in reversed((IMEM[8].data]))
print("".join([str(x) for x in IMEM[9].data]))
print("".join([str(x) for x in IMEM[10].data]))
print("".join([str(x) for x in IMEM[11].data]))
print("".join([str(x) for x in IMEM[12].data]))
print("".join([str(x) for x in IMEM[13].data]))
'''

'''
print(IMEM[7].data)
print(IMEM[8].data)
print(IMEM[9].data)
print(IMEM[10].data)
print(IMEM[11].data)
print(IMEM[12].data)
print(IMEM[13].data)
'''
# pipelined data:
class pipeline:
    def __init__(self):

        #the instuctions are of a different type than the other registers
        self.inst_d = inst_line([0]*inst_version)
        self.inst_x = inst_line([0]*inst_version)
        self.inst_m = inst_line([0]*inst_version)
        self.inst_w = inst_line([0]*inst_version)

#all "_t" come after the register that held it. e.g., inst_d goes into inst_d_t

        self.inst_d_t = inst_line([0]*inst_version)
        self.inst_x_t = inst_line([0]*inst_version)
        self.inst_m_t = inst_line([0]*inst_version)
        self.inst_w_t = inst_line([0]*inst_version)

        #pc regs:
        self.pc_f = 0 #this is also made of bits, but we dont need to include that. for the jump, we will add to the int

        # alu out
        self.alu_m = [0]*32
        self.alu_m_t = [0]*32
        self.alu_out_t = [0]*32

        # regfile regs:
        self.rs1_x = [0]*32
        self.rs2_x = [0]*32

        self.rs1_d_t = [0]*32
        self.rs2_d_t = [0]*32

        self.rs1_x_t = [0]*32
        self.rs2_x_t = [0]*32

        self.rs2_m = [0] * 32
        # self.dmemout?
        self.mux_w = [0]*32
        self.mux_w_t = [0]*32

        # controler:
        self.write_enable = 0
        self.MUX_3_flag = -1
        self.rm = [0,0,0]

        self.clk_num = 0
        self.fcsr_flags = 0
        self.halt = 0
        self.Y_0 = [0]*32
        self.pc_f_t = 0

    def clock_cycle(self):

        self.control()
        self.instructionFetch()
        self.instructionDecode()
        print('cycle', self.clk_num,':')
        print('to execute:', self.inst_x.opcode, self.inst_x.func7)
        self.execute()
        self.memory()
        self.write_back()
        self.control_forward()
        ##non - simultanasly
        if self.halt == 0:
            self.forward_tmp_reg()
        ##move temp_registers
        self.clk_num = self.clk_num + 1
        if self.pc_f == (len(IMEM)):
            return 1
        return 0

    def control(self):
# the control decides:
#1) the RM
#2) to enable writing and reading from DMEM
#3) wither data from the DMEM or data from the ALU with be written into a reg
#4)wither data will be written into the regfile

#1)
        if (self.inst_x.rm == globs.DYN_RM):
            self.rm = reg_file[32].RM
        else:
            self.rm = self.inst_x.rm  #dynamic rounding mode starts off RTZ (round to ZERO)
#2)
        self.MEM_en = close_dmem_mux
        if (self.inst_m.opcode == globs.LOAD_FP):
            self.MEM_en = load_mux
        elif (self.inst_m.opcode == globs.STORE_FP):
            self.MEM_en = store_mux

#3)
        if (self.inst_m.opcode == globs.LOAD_FP):
            self.MUX_3_flag = LW_mux #load word
        elif (self.inst_m.opcode == globs.OP_FP):
            self.MUX_3_flag = ARITH_mux #arith op

#4)
        self.rf_write_enable = 0
        if (self.inst_w.opcode != globs.STORE_FP):
            self.rf_write_enable = 1

    def instructionFetch(self):

        self.inst_f_t = IMEM[self.pc_f]
        self.pc_f_t = self.pc_f + 1  # here we will increment by one, as every address is the same length (32-bit), and it helps with the code


    def instructionDecode(self):

        self.inst_d_t = self.inst_d
        self.rs1_d_t = reg_file[arith.list_to_num(self.inst_d.rs1)]
        self.rs2_d_t = reg_file[arith.list_to_num(self.inst_d.rs2)]

    def execute(self):

        self.inst_x_t = self.inst_x
        self.rs2_x_t = self.rs2_x

        if (self.inst_x.func7 == globs.FADD):
            self.alu_out_t = arith.add_reg(self.rs1_x, self.rs2_x, self.rm)
            #print('first arg: %.20f second arg: %.39f'%(arith.register_32_f(self.rs1_x).val,arith.register_32_f(self.rs2_x).val))
            #print('FADD result:',arith.register_32_f(self.alu_out_t).val)
            print('FADD result:',self.alu_out_t)

        if (self.inst_x.func7 == globs.FSUB):
            self.alu_out_t = arith.sub_reg(self.rs1_x, self.rs2_x, self.rm)
            #print('FSUB result:',arith.register_32_f(self.alu_out_t).val)
            print('FSUB result:', self.alu_out_t)
        if (self.inst_x.func7 == globs.FMUL):
            self.alu_out_t, self.fcsr_flags = arith.mul_reg(self.rs1_x, self.rs2_x, self.rm)
            #print('FMUL result:',arith.register_32_f(self.alu_out_t).val)
            print('FMUL result:', self.alu_out_t)
            self.update_fcsr()
        if (self.inst_x.func7 == globs.FDIV):
            self.alu_out_t, self.err_flag = arith.div_reg(self.rs1_x, self.rs2_x, self.rm)
            #print('FDIV result:',arith.register_32_f(self.alu_out_t).val)
            print('FDIV result:',self.alu_out_t)
        if (self.inst_x.func7 == globs.FCVT_I_F):
            self.alu_out_t = arith.int_to_float(self.rs1_x, self.rm)
            print('INT_2_FP result:',arith.register_32_f(self.alu_out_t).val)
        if (self.inst_x.func7 == globs.FCMP):
            self.alu_out_t = arith.compare_reg(self.rs1_x, self.rs2_x, self.inst_x.rm)
            #print('FCMP result:',arith.register_32_f(self.alu_out_t).val)
            print('FCMP result:', self.alu_out_t)
        if (self.inst_x.func7 == globs.FMM):
            self.alu_out_t = arith.min_max(self.rs1_x, self.rs2_x, self.inst_x.rm)
            # print('FCMP result:',arith.register_32_f(self.alu_out_t).val)
            print('FMM result:', self.alu_out_t)
        if (self.inst_x.opcode == globs.LOAD_FP):
            self.alu_out_t = arith.add_reg_imm(self.rs1_x, self.inst_x.imm11_0)
        if (self.inst_x.opcode == globs.STORE_FP):
            self.alu_out_t = arith.add_reg_imm(self.rs1_x, self.inst_x.imm4_0 + self.inst_x.imm11_5)


        if (self.inst_x.func7 == globs.FSQRT):
#how this works:
#if the halt is 0, the pipeline moves.
#if the halt is not 0,the pipeline stays until it is 0

            if self.halt == 0:
                self.halt = 6
            self.rs1_x, self.rs2_x, self.alu_out_t, self.Y_0, self.halt = arith.sqrt_reg(self.rs1_x, self.rs2_x, self.alu_out_t, self.Y_0, self.halt)
            #print('FSQRT result:', arith.register_32_f(self.alu_out_t).val)
            print('FSQRT result:', self.alu_out_t)

    def memory(self):
        self.inst_m_t = self.inst_m
        if (self.MEM_en == load_mux):
            self.mux_w_t = DMEM[arith.list_to_num(self.alu_m)]
        elif (self.MEM_en == store_mux):
            print(arith.list_to_num(self.alu_m))
            DMEM[arith.list_to_num(self.alu_m)] = self.rs2_m
        else:
            self.mux_w_t = self.alu_m

        #print(DMEM[arith.list_to_num(self.alu_m)])

    def write_back(self):
        if (self.rf_write_enable):
            reg_file[arith.list_to_num(self.inst_w.rd)] = self.mux_w

    def control_forward(self):
#inthe simulation,we override the registers. in the rtl, we will have a flag in the controler for a forwarding mux
        if (self.inst_d.rs1 == self.inst_x.rd and self.inst_x.opcode == globs.OP_FP and self.clk_num > 0): #this is only for OP_FP. we do not support instructions that need forwarding from LW
            self.rs1_d_t = self.alu_out_t
        elif (self.inst_d.rs1 == self.inst_m.rd and self.clk_num > 1):
            print('forwarding 1:')
            self.rs1_d_t = self.mux_w_t
            print(self.rs1_d_t)
        elif (self.inst_d.rs1 == self.inst_w.rd and self.inst_w.opcode != globs.STORE_FP and self.clk_num > 2):
            self.rs1_d_t = reg_file[arith.list_to_num(self.inst_w.rd)]

        if (self.inst_d.rs2 == self.inst_x.rd and self.inst_m.opcode == globs.OP_FP and self.clk_num > 0):
            self.rs2_d_t = self.alu_out_t
            print('forwarding 2:')
            print(self.rs2_d_t)
        elif (self.inst_d.rs2 == self.inst_m.rd and self.clk_num > 1):
            self.rs2_d_t = self.mux_w_t
        elif (self.inst_d.rs2 == self.inst_w.rd and self.inst_w.opcode != globs.STORE_FP and self.clk_num > 2):
            self.rs2_d_t = reg_file[arith.list_to_num(self.inst_w.rd)]

        ##TODO: forwarding for arithmetic
        ##if rs1 or rs2 of inst_D == rd of inst_x or inst_mor inst_w and rd was edited(make sure its correct)

        ##TODO: forwarding for load word

        ##TODO: forwarding for FCOMPARE

    def forward_tmp_reg(self):

        self.pc_f = self.pc_f_t
        # fetch to decode
        self.inst_d = self.inst_f_t

        # decode to exe
        self.inst_x = self.inst_d_t
        self.rs1_x = self.rs1_d_t
        self.rs2_x = self.rs2_d_t

        # exe to mem
        self.inst_m = self.inst_x_t
        self.rs2_m = self.rs2_x_t
        self.alu_m = self.alu_out_t

        # mem to wb
        self.inst_w = self.inst_m_t
        self.mux_w = self.mux_w_t


    def update_fcsr(self):
        if self.fcsr_flags == arith.overflow:
            reg_file[32].OF = 1
        if self.fcsr_flags == arith.underflow:
            reg_file[32].UF = 1

finished = 0
pipeline = pipeline()
while not finished:
    finished = pipeline.clock_cycle()

print('final result:', arith.register_32_f(reg_file[4]).val)

