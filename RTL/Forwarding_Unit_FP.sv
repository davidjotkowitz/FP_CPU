//=============================================================================+
// Forwarding Unit Module : decides wether to forward needed data by the       |
//                          instruction in the ID or the EXE.                  |
//                                                                             |
//=============================================================================+

module Forwarding_Unit(
    input  logic         executionStage_instruction_writing_to_rf_indicator,
    input  logic         memStage_instruction_writing_to_rf_indicator,
    input  logic         writeBackStage_instruction_writing_to_rf_indicator,
    input  logic [4 : 0] destination_register_in_executionStage,
    input  logic [4 : 0] destination_register_in_memStage,
    input  logic [4 : 0] destination_register_in_writeBackStage,
    input  logic [4 : 0] first_source_register_in_IDStage,
    input  logic [4 : 0] second_source_register_in_IDStage,
    input  logic [4 : 0] first_source_register_in_executionStage,
    input  logic [4 : 0] second_source_register_in_executionStage,
    output logic [1 : 0] forwarded_data_source_for_rs1_in_IDStage,
    output logic [1 : 0] forwarded_data_source_for_rs2_in_IDStage,
    output logic [1 : 0] forwarded_data_source_for_rs1_in_EXEStage,
    output logic [1 : 0] forwarded_data_source_for_rs2_in_EXEStage
);

    always_comb
    begin
        //From ALU & MEM to ALU
        if( memStage_instruction_writing_to_rf_indicator && destination_register_in_memStage != '0 &&
            destination_register_in_memStage == first_source_register_in_executionStage ) begin
          forwarded_data_source_for_rs1_in_EXEStage = 2'b10;        //forward alu res to alu
        end
        else if( writeBackStage_instruction_writing_to_rf_indicator && destination_register_in_writeBackStage != '0 &&
                  destination_register_in_writeBackStage == first_source_register_in_executionStage ) begin
          forwarded_data_source_for_rs1_in_EXEStage = 2'b01;        //forward mem res to alu
        end
        else begin
          forwarded_data_source_for_rs1_in_EXEStage = 2'b00;
        end

        if( memStage_instruction_writing_to_rf_indicator && destination_register_in_memStage != '0 &&
            destination_register_in_memStage == second_source_register_in_executionStage ) begin
          forwarded_data_source_for_rs2_in_EXEStage = 2'b10;       //forward alu res to alu
        end
        else if( writeBackStage_instruction_writing_to_rf_indicator && destination_register_in_writeBackStage != '0 &&
                destination_register_in_writeBackStage == second_source_register_in_executionStage ) begin
          forwarded_data_source_for_rs2_in_EXEStage = 2'b01;       //forward mem res to alu
        end
        else begin
          forwarded_data_source_for_rs2_in_EXEStage = 2'b00;
        end

        //FROM ALU & MEM to ID (for branches)
        if( executionStage_instruction_writing_to_rf_indicator && destination_register_in_executionStage !='0 &&
            destination_register_in_executionStage == first_source_register_in_IDStage ) begin
          forwarded_data_source_for_rs1_in_IDStage = 2'b10;        //forward alu res to id
        end
        else if( memStage_instruction_writing_to_rf_indicator && destination_register_in_memStage !='0 &&
                destination_register_in_memStage == first_source_register_in_IDStage ) begin
          forwarded_data_source_for_rs1_in_IDStage = 2'b01;        //forward mem res to id
        end
        else begin
          forwarded_data_source_for_rs1_in_IDStage = 2'b00;
        end

        if( executionStage_instruction_writing_to_rf_indicator && destination_register_in_executionStage !='0 &&
            destination_register_in_executionStage == second_source_register_in_IDStage ) begin
          forwarded_data_source_for_rs2_in_IDStage = 2'b10;        //forward alu res to id
        end
        else if( memStage_instruction_writing_to_rf_indicator && destination_register_in_memStage !='0 &&
                destination_register_in_memStage == second_source_register_in_IDStage ) begin
          forwarded_data_source_for_rs2_in_IDStage = 2'b01;        //forward mem res to id
        end
        else begin
          forwarded_data_source_for_rs2_in_IDStage = 2'b00;
        end
    end

endmodule
