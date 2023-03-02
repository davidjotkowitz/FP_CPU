//=============================================================================+
// Instruction Decode Module : decodes the instruction fetched from the        |
//                             the instruction fetch stage in the previous     |
//                             clock cycle.                                    |
//=============================================================================+

module Instruction_Decode_FP(
    input  logic          clk,
    input  logic          reset,
	input  logic          halt,
    input  logic [31 : 0] instruction,
    input  logic [1  : 0] forward_source_for_rs1,
    input  logic [1  : 0] forward_source_for_rs2,
    input  logic [31 : 0] forwarded_result_from_ALU,
    input  logic [31 : 0] forwarded_result_from_Mem,
    input  logic          return_address_JAL,
    input  logic [4  : 0] return_address_reg,
    input  logic [7  : 0] return_address,
    input  logic          register_write_enable,
    input  logic [4  : 0] destination_register,
    input  logic [31 : 0] value_to_write_to_reg,
    output logic [31 : 0] first_operand_value,
    output logic [31 : 0] second_operand_value///,
	///output logic [31 : 0] third_operand_value,
    ///output logic [31 : 0] immediate_value

);


    logic  [31 : 0]x[0 : 31]; // RF//YUVAL TODO: write values here and check
	 ///std::randomize (x);
	 /*
	 
	 assign x[7] = 32'hffffffff;
	 assign x[2] = 32'heeeeeeee;
	 assign x[3] = 32'hdddddddd;
	 assign x[4] = 32'hcccccccc;
	 assign x[5] = 32'hbbbbbbbb;
	 assign x[6] = 32'haaaaaaaa;
	 assign x[8] = 32'h99999999;
	 assign x[9] = 32'h88888888;
	 assign x[10] = 32'hdeadbeef;
	 */
	 
	 /*
	 assign x[13] = {32'h5678};
	 assign x[14] = {32'h9abc};
	 assign x[15] = {32'hdef0};
	 */
	 /*
	 assign x[22] = 32'h12340000;
	 assign x[23] = 32'h56780000;
	 assign x[24] = 32'h9abc0000;
	 assign x[25] = 32'hdef00000;
	 */

    always_ff @(negedge clk) // write to rd in negedge
    if(reset)
	 begin
        x <= '{default:'0};
	 end
    else if (!halt) //changed here, maybe need another place FP
    begin
        if(return_address_JAL && return_address_reg != '0) begin
            x[return_address_reg] <= return_address;
        end
        if(register_write_enable && destination_register != '0) begin
            x[destination_register] <= value_to_write_to_reg;
        end
    end

    logic [4  : 0] first_source_reg, second_source_reg;
    assign first_source_reg = instruction[19 : 15];
    assign second_source_reg = instruction[24 : 20];

    logic [31 : 0] first_operand, second_operand;

    always_comb
    case(forward_source_for_rs1)
        2'b00:
            first_operand = x[first_source_reg];
        2'b01:
            first_operand = forwarded_result_from_Mem;
        2'b10:
            first_operand = forwarded_result_from_ALU;
        default:
            first_operand = x[first_source_reg];
    endcase

    always_comb
    case(forward_source_for_rs2)
        2'b00:
            second_operand = x[second_source_reg];
        2'b01:
            second_operand = forwarded_result_from_Mem;
        2'b10:
            second_operand = forwarded_result_from_ALU;
        default:
            second_operand = x[second_source_reg];
    endcase

    assign  first_operand_value   = first_operand;
    assign  second_operand_value  = second_operand;
	///assign  third_operand_value  = instruction[31 : 27];///for F[N]MADD/SUB FP ////MAYBE NOT NEEDED
/*
    always_comb
    case(instruction[6 : 0])
        7'b0100011: //STORE
            immediate_value = 32'(signed'({instruction[31 : 25], instruction[11 : 7]}));
        7'b0110111: //LUI
            immediate_value = {instruction[31 : 12], 12'd0};
        7'b0010111: //AUIPC
            immediate_value = {instruction[31 : 12], 12'd0};
        default:
            immediate_value = 32'(signed'(instruction[31 : 20])) ;
    endcase
*/
endmodule
