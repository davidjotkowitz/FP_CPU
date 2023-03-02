//=============================================================================+
// Hazard Detection Unit Module : decides whether there is a load hazard or    |
//                                a branch hazard.                             |
//                                                                             |
//=============================================================================+

module Hazard_Detection_Unit(
    input  logic         load_instruction_in_EXEStage,
    input  logic [4 : 0] destination_register_of_EXeStage_instruction,
    input  logic [4 : 0] first_source_register_of_IDStage_instruction,
    input  logic [4 : 0] second_source_register_of_IDStage_instruction,
    input  logic         the_branch_is_taken,
    output logic         hazard_barnch_is_taken_indicator,
    output logic         hazard_load_instruction_indicator
);

    always_comb
    begin
        hazard_barnch_is_taken_indicator = the_branch_is_taken;
        hazard_load_instruction_indicator = 1'b0;
        if( load_instruction_in_EXEStage && ( destination_register_of_EXeStage_instruction == first_source_register_of_IDStage_instruction ||
            destination_register_of_EXeStage_instruction == second_source_register_of_IDStage_instruction )) begin
            hazard_load_instruction_indicator = 1'b1;
        end
    end

endmodule
