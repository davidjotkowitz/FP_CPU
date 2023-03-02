//=============================================================================+
// Execution Unit Module : executes the needed operation by the instruction.   |
//                                                                             |
//                                                                             |
//=============================================================================+

module Execution_Unit_FP(
    input  logic          clk,
    input  logic          reset,
    input  logic [31 : 0] instruction,
    input  logic          source_of_first_alu_operand,
    input  logic          source_of_second_alu_operand,
    input  logic [2  : 0] kind_of_calculation,
    input  logic          calculate_logical_or_arithmetic,
    input  logic [4  : 0] destination_register,
    input  logic          load_instruction_indicator,
    input  logic          store_instruction_indicator,
    input  logic [2  : 0] FUNC3_of_load_store_instructions,
    input  logic          register_file_write_enable,
    input  logic          source_for_register_writing_ALU_or_MEM,
    input  logic [31 : 0] first_operand_of_instruction,
    input  logic [31 : 0] second_operand_of_instruction,
    input  logic [31 : 0] immediate_value,
    input  logic [31 : 0] pc,
    input  logic [1  : 0] forward_of_ALU_or_mem_to_rs1,
    input  logic [1  : 0] forward_of_ALU_or_mem_to_rs2,
    input  logic [31 : 0] forwarded_data_from_MemStage,
    input  logic [31 : 0] forwarded_data_from_writeBackStage,
    output logic [31 : 0] execution_output,
	 output logic			  halt_sqrt
);

    logic [31 : 0] first_operand_decision_making, second_operand_decision_making, immediate_value_to_calculate;

    always_comb
    begin
      // first operand
      if(source_of_first_alu_operand) begin
        if(instruction[6 : 0] == 7'b0110111) begin //LUI
          first_operand_decision_making = '0;
        end
        else begin
          first_operand_decision_making = pc;
        end
      end
      else begin
        if(forward_of_ALU_or_mem_to_rs1 == 2'b10) begin
          first_operand_decision_making = forwarded_data_from_MemStage;
        end
        else if(forward_of_ALU_or_mem_to_rs1 == 2'b01) begin
          first_operand_decision_making = forwarded_data_from_writeBackStage;
        end
        else begin
          first_operand_decision_making = first_operand_of_instruction;
        end

        if(instruction[6 : 0] == 7'b0110111) begin //LUI
          first_operand_decision_making = '0;
        end
      end

      // second operand
      if(source_of_second_alu_operand) begin
        second_operand_decision_making = immediate_value_to_calculate;
      end
      else begin
        if(forward_of_ALU_or_mem_to_rs2 == 2'b10) begin
          second_operand_decision_making = forwarded_data_from_MemStage;
        end
        else if(forward_of_ALU_or_mem_to_rs2 == 2'b01) begin
          second_operand_decision_making = forwarded_data_from_writeBackStage;
        end
        else begin
          second_operand_decision_making = second_operand_of_instruction;
        end
      end
    end


    // immediate value
    assign immediate_value_to_calculate = immediate_value;

    Arithmetic_Logic_Unit_FP ALU_instance (
        .first_operand                   (first_operand_decision_making),
        .second_operand                  (second_operand_decision_making),
        .inst_x         					  (instruction),
        .calculate_logical_or_arithmetic (calculate_logical_or_arithmetic),
        .calculation_output              (execution_output),
		  .is_FP									  (1'b1),//can be modified in further projects
		  .rst									  (reset),
		  .clk									  (clk),
		  .halt								     (halt_sqrt),
		  .RM										  (instruction[14:12])
    );


endmodule
