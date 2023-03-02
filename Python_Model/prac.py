import os
import shutil
import base

RV_version = 32
inst_version = 32
data_version = 32 ##float or double


class globs:
    LOAD_FP = [0,0,0,0,1,1,1]
    STORE_FP = [0,1,0,0,1,1,1]
    OP_FP = [1,0,1,0,0,1,1]
    FNMADD = [1,0,0,1,1,1,1]
    FNMSUB = [1,0,0,1,0,1,1]
    FMADD = [1,0,0,0,0,1,1]
    FMSUB = [1,0,0,0,1,1,1]
    JAL = [1,1,0,1,1,1,1]



import struct
#import pandas as pd
def binary(num):
    return ''.join('{:0>8b}'.format(c) for c in struct.pack('!f', num))

def split(word):
    return [int(char) for char in word]

'''
number = binary(2.1)
print(split(number))

from riscv_assembler.convert import AssemblyConverter
cnv = AssemblyConverter()
cnv.convert("testa.s")

file = open("testa/bin/testa.bin", "rb")

byte = file.read()
print('here')
print(type(byte))

#print(testa.bin)
file.close()
shutil.rmtree("testa")

'''

class pipeline:
    def __init__(self):

        self.inst_d = base.inst_line([0]*inst_version)
        self.inst_x = base.inst_line([0]*inst_version)
        self.inst_m = base.inst_line([0]*inst_version)
        self.inst_w = base.inst_line([0]*inst_version)

        self.inst_d_t = base.inst_line([0]*inst_version)
        self.inst_x_t = base.inst_line([0]*inst_version)
        self.inst_m_t = base.inst_line([0]*inst_version)
        self.inst_w_t = base.inst_line([0]*inst_version)
        # pc regs
        self.pc_f = [0]*32
        self.pc_x = [0]*32
        self.pc_m = [0]*32

        self.pc_plus_4 = [0]*32

        self.pc_f_t = [0]*32
        self.pc_x_t = [0]*32
        self.pc_m_t = [0]*32
        # alu out
        self.alu_m = [0]*32
        self.alu_m_t = [0]*32
        # regfile regs
        self.rs1_x = [0]*32
        self.rs2_x = [0]*32
        self.rs3_x = [0]*32

        self.rs1_d_t = [0]*32
        self.rs2_d_t = [0]*32
        self.rs3_d_t = [0]*32

        self.rs1_x_t = [0]*32
        self.rs2_x_t = [0]*32
        self.rs3_x_t = [0]*32
        # self.dmemout?
        self.mux_w = [0]*32
        self.DATA_R = [0]*32
        self.mux_w_t = [0]*32

        # controler:
        self.jump_res=0
        self.write_enable=0

        #reg_file

        self.reg_file = base.reg_file(data_version)

    def instructionFetch(self):
        ##no need for temp for next line only
        self.pc_f_plus_4 = self.pc_f + 4
        self.pc_f_t = self.pc_f
        ##inst_D = MEM[pc_F]
        self.inst_f_t = base.IMEM[self.pc_f]
        if (self.jmp_res):
            self.pc_f = self.alu_m
        else:
            self.pc_f += 4

    def instructionDecode(self):
        # inst_x = inst_D
        self.inst_d_t = self.inst_d
        # pc_X = pc_D
        self.pc_d_t = self.pc_D
        self.rs1_d_t = self.reg_file.mem_array[self.inst_D.rs1]  #regfile
        self.rs2_d_t = reg_file[inst_D.rs2]
        self.rs3_d_t = reg_file[inst_D.rs3]

    def Execute(self):
        self.inst_x_t = self.inst_x
        self.pc_x_t = self.pc_x
        self.rs2_x_t = self.rs2_x
        ##branch_cmp

        # alu
        reg_file[fscr].rm = pc_M.rm
        if (pc_M.opcode == globs.OP_FP):
            if (pc_M.func5 == globs.FADD):
                self.alu_out_t = add_reg(rs1_x,rs2_x)
            if (pc_M.func5 == globs.FSUB):
                self.alu_out_t = sub_reg(rs1_x,rs2_x)
            if (pc_M.func5 == globs.FMUL):
                self.alu_out_t = mul_reg(rs1_x,rs2_x)
            if (pc_M.func5 == globs.FDIV):
                self.alu_out_t = div_reg(rs1_x,rs2_x)
            if (pc_M.func5 == globs.FCMP):
                if (pc_M.rm == globs.MIN):
                    self.alu_out_t = min(rs1_x, rs2_x)
                else:
                    self.alu_out_t = max(rs1_x, rs2_x)

        elif (pc_M.opcode == globs.FMADD):
            self.alu_out_t = rs1_x * rs2_x + rs3_x
        elif (pc_M.opcode == globs.FNMADD):
            self.alu_out_t = -(rs1_x * rs2_x + rs3_x)
        elif (pc_M.opcode == globs.FSUB):
            self.alu_out_t = rs1_x * rs2_x - rs3_x
        elif(pc_M.opcode == FNSUB):
            self.alu_out_t = -(rs1_x * rs2_x - rs3_x)
        else:
            print('illegal')

        return;
        ##branch comp in the control ()


    def Memory(self):
        self.inst_m_t = self.inst_m

        self.pc_plus_4_M = self.pc_M+4

        if(LOAD_flag):
            self.DATA_R = self.DMEM_r(self.alu_M)
        if(STORE_flag):
            self.DMEM[self.alu_M] = self.rs2_m


        if (MUX_3_flag == 0):
            self.MUX_w_t=self.pc_M+4
        elif (self.MUX_3_flag == 1):
            self.MUX_w_t=self.DATA_R
        elif (self.MUX_3_flag == 2):
            self.MUX_w_t=self.alu_M
        return;

    def Write_back(self):
        if(self.write_enable):
            self.reg_file.Datad = self.MUX_w
            self.reg_file.Addrd = self.inst_w.rd
        return;

    def forward_tmp_reg(self):
        #fetch to decode
        self.pc_D = self.pc_F_t
        self.inst_D = self.inst_F_t

        #decode to exe
        self.inst_x = self.inst_D_t
        self.pc_X = self.pc_D_t
        self.rs1_x = self.rs1_D_t
        self.rs2_x = self.rs2_D_t
        self.rs3_x = self.rs3_D_t

        #exe to mem
        self.inst_m = self.inst_x_t
        self.pc_M = self.pc_X_t
        self.rs2_m = self.rs2_x_t
        self.alu_M = self.alu_out_t

        #mem to wb
        self.inst_w = self.inst_m_t
        self.mux_w = self.mux_w_t
        ##wb to??
        return;

    def control(self):
        ##IF
        #nothing here (see EXE)

        # ID
        #nothing here

        # EXE
        ##here we get the control signal for next IF
        compare_res_1 = (self.rs1_x >= self.rs2_x)
        compare_res_2 = (self.rs1_x > self.rs2_x)
        self.jmp_res = 0 ##default
        if (self.inst_x.func5 == globs.FCMP):
            if (self.inst_x.rm == globs.EQ):
                self.jmp_res = (compare_res1 and not compare_res2)
            if (inst_x.rm == globs.LT):
                self.jmp_res = (compare_res_1)
            if (inst_x.rm == globs.LE):
                self.jmp_res = (compare_res_2)

        # MEM
        self.LOAD_flag = 0
        self.STORE_flag = 0
        #if read
        if (self.inst_m.opcode == globs.LOAD_FP):
            self.LOAD_flag=1
        #if write
        if(self.inst_m.opcode == globs.STORE_FP):
            self.STORE_flag = 1

        ###to mux 3
        self.MUX_3_flag = -1
        if (self.inst_m.opcode == globs.JAL):
            self.MUX_3_flag = 0
        elif (self.inst_m.opcode == globs.LOAD_FP):
            self.MUX_3_flag = 1
        ##TODO: this elese may be problematic
##        else (self.inst_m.opcode == OP - FP):##TODO: get op-codes for arithmetic operations, maybe its not right (because of  FCVT)
##            self.MUX_3_flag = 2
        else:
            self.MUX_3_flag = 2
        # WB
        self.write_enable = 1
        if (inst_w.func5 != FCMP & inst_w.opcode != STORE_FP):
            self.write_enable = 0
        return;

    def clock_cycle(self):


        ##simultanasly
        ## was pipeline.control() and so on
        self.control()
        self.instructionFetch()
        self.instructionDecode()
        self.Execute()
        self.Memory()
        self.Write_back()

        ##Important: we do it here to write over temps
        pipeline.control_forward()

        ##non - simultanasly
        pipeline.forward_tmp_reg()
        ##move temp_registers
        return


        #NOP's opcode - 0x00000013

    ###########all of the above is done#########

    def control_forward(self):###inst_D, inst_x, inst_m, inst_w,self.rs1_x,self.rs2_x):
        ##TODO: make sure if the instruction we forward uses rd. if not - continue

        if (inst_D.rs1==inst_x.rd):
            self.rs1_x = self.alu_M
        elif (inst_D.rs1==inst_m.rd):
            self.rs1_x = self.mux_w
        elif (inst_D.rs1 == inst_w.rd):
            self.rs1_x =  reg_file[inst_w.rd] ##TODO: maybe self.reg_file[inst_w.rd]

        if (inst_D.rs2==inst_x.rd):
            self.rs2_x = self.alu_M
        elif (inst_D.rs2==inst_m.rd):
            self.rs2_x = self.mux_w
        elif (inst_D.rs2 == inst_w.rd):
            self.rs2_x =  reg_file[inst_w.rd] ##TODO: maybe self.reg_file[inst_w.rd]

        ##TODO: forwarding for arithmetic
        ##if rs1 or rs2 of inst_D == rd of inst_x or inst_mor inst_w and rd was edited(make sure its correct)

        ##TODO: forwarding for load word

        ##TODO: forwarding for FCOMPARE
        return

    def DMEM_r(self):
        return DMEM[alu_M]

class globs:  #might want to change everything to bits class
    LOAD_FP = [0,0,0,0,1,1,1]
    STORE_FP = [0,1,0,0,1,1,1]
    OP_FP = [1,0,1,0,0,1,1]
    FNMADD = [1,0,0,1,1,1,1]
    FNMSUB = [1,0,0,1,0,1,1]
    FMADD = [1,0,0,0,0,1,1]
    FMSUB = [1,0,0,0,1,1,1]


    #fmt:
    S = [0,0]
    D = [0,1]
    Q = [1,1]

    #funct5:
    FADD = [0,0,0,0,0,0,0]
    FSUB = [0,0,0,0,1,0,0]
    FMUL = [0,0,0,1,0,0,0]
    FDIV = [0,0,0,1,1,0,0]
    FCMP = [0,0,1,0,1,0,0]
    FSQRT = [0,1,0,1,1,0,0]
    #FCMPFMIN-MAX = [0,0,1,0,1,0,0] this is FCMP
    FCLASS = [1,1,1,0,0,0,0]
    FSGNJ = [0,0,1,0,0,0,0]
    '''
    FCVT_S_D = []
    FCVT.D.S = []
    FCVT.S.Q = []
    FCVT.Q.S = []
    FCVT.D.Q =[]
    FCVT.Q.D = []
    FCVT.I.F = []
    FCVT.F.I = []
    '''
    #rm:
    J = [0,0,0]
    JN = [0,0,1]
    JX = [0,1,0]
    MIN = [0,0,0]
    MAX = [0,0,1]
    RNE = [0,0,0]
    RTZ = [0,0,1]
    RDN = [0,1,0]
    RUP = [0,1,1]
    RMM = [1,0,0]
    #101 110 invalid, 111 "dynamic rounding mode"
    EQ = [0,1,0]
    LT = [0,0,1]
    LE = [0,0,0]

    #define NOP