//=============================================================================+
// Instruction Fetch Module : fetches an instruction every given clock cycles  |
//                            by reaching the instructions memory addressed    |
//                            pointed by the current pc.                       |
//=============================================================================+


module Instruction_Fetch_FP(
    input  logic          clk,
    input  logic          reset,
	input  logic          halt,  ///we added this FP. used for multiclock op's like sqrt
    input  logic          hazard_load_indicator,
    input  logic          branched_address_indicator,
    input  logic [7  : 0] address_to_branch,
    output logic [31 : 0] instruction,
    output logic [31 : 0] pc
);

    logic   [7 : 0]    pc_decision_making;

    always_ff @(posedge clk)
    if(reset) begin
        pc_decision_making <= '0;
      end
    else if(!hazard_load_indicator && !halt) begin //changed here for halting FP
        if(branched_address_indicator) begin
            pc_decision_making <= address_to_branch;
          end
        else begin
            pc_decision_making <= pc + 32'd4;
          end
        end

    assign pc = pc_decision_making;

    Instructions_Memory_FP IMem_instance (
              .pc          (pc_decision_making),
              .instruction (instruction)
            );

endmodule
