//=============================================================================+
// Arithmetic Logic Unit Module : calculates arithmetically or logically.      |
//                                                                             |
//TODO: get op-code (קידומת) for FP and FOR INT and make an "if" statment to handle different op's                                                                             |
//=============================================================================+

module Arithmetic_Logic_Unit_FP(
  input  logic [31 : 0] first_operand,      // first operand
  input  logic [31 : 0] second_operand,     // second operand
  input  logic [31 : 0] inst_x,
  input  logic [2 : 0] RM,///Rounding Mode. the control will send either from instruction, or fcsr
  output logic [31 : 0] calculation_output,     // the result of the calculation
    input  logic          calculate_logical_or_arithmetic, // arithmetic or logic
  output logic [3:0] halt,
  input logic is_FP,
  input  logic			rst,//transfer to FSQRT
  input  logic			clk//transfer to FSQRT
  );
  
  // Design parameters
 //`include "params_final.inc"
 
   localparam
	FADD = 7'b0000000,
	FSQRT = 7'b0101100, 
	FSUB = 7'b0000100,
	FMUL = 7'b0001000, 
	FDIV = 7'b0001100, 
	FCMP = 7'b1010000,
	FMM  = 7'b0010100;

  
  logic [31 : 0] FADD_output;
  logic [31 : 0] FSUB_output;
  logic [31 : 0] FMUL_output;
  logic [31 : 0] FDIV_output;
  logic [31 : 0] FSQRT_output;
  logic [31 : 0] FMIN_MAX_output;
  logic [31 : 0] FCMP_output;
  logic [31 : 0] FMM_output;

   logic [6 : 0]  instruction_FUNC7_field;
   logic [3 : 0]  instruction_FUNC3_field;
	assign  instruction_FUNC7_field = inst_x[31 : 25];
	assign instruction_FUNC3_field = inst_x[14 : 12];
	
	logic sqrt_valid;
	
	FADD add_inst (.first_operand(first_operand),.second_operand(second_operand),.calculation_output(FADD_output));
	FSUB sub_inst (.first_operand(first_operand),.second_operand(second_operand),.calculation_output(FSUB_output));
	FMUL mul_inst (.first_operand(first_operand),.second_operand(second_operand),.calculation_output(FMUL_output));
	FDIV div_inst (.first_operand(first_operand),.second_operand(second_operand),.calculation_output(FDIV_output));
	FCMP cmp_inst (.first_operand(first_operand),.second_operand(second_operand),.calculation_output(FCMP_output), .RM(RM));
	FMIN_MAX mm_inst (.first_operand(first_operand),.second_operand(second_operand),.calculation_output(FMM_output), .RM(RM));
	FSQRT sqrt_inst (.rst(rst), .clk(clk),.valid(sqrt_valid),.reg_orig(first_operand),.reg_out(FSQRT_output), .halt(halt));

		
	
	always_comb 
	begin
	if (is_FP) begin
			case(instruction_FUNC7_field) //FUNC5
				
				FADD:
						begin
						sqrt_valid = 1'b0;
						calculation_output = FADD_output;
						end
				FSUB:
						begin
						calculation_output = FSUB_output;
					 	sqrt_valid = 1'b0;
						end
				FMUL:
						begin
						calculation_output = FMUL_output;
						sqrt_valid = 1'b0;
						end
				FDIV:
						begin
						calculation_output = FDIV_output;
						sqrt_valid = 1'b0;
						end
				FSQRT: //FSQRT
						begin
						calculation_output = FSQRT_output;
						sqrt_valid = 1'b1;
						end
				FCMP:
						begin
						calculation_output = FCMP_output;
						sqrt_valid = 1'b0;
						end
				FMM:
						begin
						calculation_output = FMM_output;
						sqrt_valid = 1'b0;
						end
				default:
					begin
					calculation_output = '0;
					sqrt_valid = 1'b0;
					end
			endcase
			end
		
		
		/*
		else//F[N]_MADD_MSUB
			begin
			calculation_output = FMADD_MSUB_output;		
			end
		end
		*/
			
			
		
				else begin//!is_FP
										sqrt_valid = 1'b0;
				case(instruction_FUNC3_field) //FUNC3
				
				3'b000: //ADD_SUB_ADDI_STORE_LOAD //saved this for adddress calc, nothing else. the FP-ADD is above and different
					if(calculate_logical_or_arithmetic)
					  calculation_output = first_operand - second_operand;
					else
					  calculation_output = first_operand + second_operand;

				3'b001: //SLL_SLLI
					calculation_output = first_operand << second_operand[4:0];

				3'b010: //SLT_SLTI
					if(signed'(first_operand) < signed'(second_operand))
					  calculation_output = { {31{1'b0}}, 1'b1};
					else
					  calculation_output = '0;

				3'b011: //SLTU_SLTIU
					if(unsigned'(first_operand) < unsigned'(second_operand))
					  calculation_output = { {31{1'b0}}, 1'b1};
					else
					  calculation_output = '0;

				3'b100: //XOR_XORI
					calculation_output = first_operand ^ second_operand;

				3'b101: //SRL_SRA_SRLI_SRAI
					if(calculate_logical_or_arithmetic)
					  calculation_output = first_operand >>> second_operand[4:0];
					else
					  calculation_output = first_operand >> second_operand[4:0];

				3'b110: //OR_ORI
					calculation_output = first_operand | second_operand;

				3'b111: //AND_ANDI
					calculation_output = first_operand & second_operand;


				default:
					begin
					calculation_output = {32{1'b0}};

					end
        endcase
		end
		end
	
    

endmodule
