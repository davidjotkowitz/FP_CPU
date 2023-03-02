//=============================================================================+
// Memory Unit Module : for loading and storing data in the data memory.       |
//                                                                             |
//TODO: check if halt is needed, i think it is                                                                             |
//=============================================================================+

module Memory_Unit_FP(
    input  logic          clk,
    input  logic          reset,
    input  logic          instruction_writing_to_memory,
    input  logic [31 : 0] data_to_write,
    input  logic [7  : 0] memory_address,
    input  logic [2  : 0] load_store_instructions_FUNC3,
    output logic [31 : 0] memory_output,
	
	input  logic		  halt
);

    logic [31 : 0] data_to_write_making_decision, data_to_read_making_decision, data_to_read;

    always_comb
    begin
	
		//if(!halt)
		//begin
			case( load_store_instructions_FUNC3 )

				3'b000: //SB: Store Byte
					data_to_write_making_decision = {24'd0, data_to_write[7:0]};

				3'b001: //SH: Store Half Word
					data_to_write_making_decision = {16'd0, data_to_write[15:0]};

				3'b010: //SW: Store Word
					data_to_write_making_decision = data_to_write;

				default:
					data_to_write_making_decision = data_to_write;
			endcase
		//end
    end


    always_comb
    begin
		//if(!halt)
		//begin
			case( load_store_instructions_FUNC3 )

				3'b000: //LB: Load Byte
					data_to_read_making_decision = 32'(signed'(data_to_read[7:0]));

				3'b001: //LH: Load Half Word
					data_to_read_making_decision = 32'(signed'(data_to_read[15:0]));

				3'b010: // LW: Load Word
					data_to_read_making_decision = data_to_read;

				3'b100: //LBU: Load Byte Unsigned
					data_to_read_making_decision = {24'd0, data_to_read[7:0]};

				3'b101: //LHU: Load Half Word Unsigned
					data_to_read_making_decision = {16'd0, data_to_read[15:0]};

				default:
					data_to_read_making_decision = data_to_read;
			endcase
		//end
    end

    assign memory_output = data_to_read_making_decision;

    Data_Memory DMem_instance (
      .clk           (clk),
      .reset         (reset),
      .address       (memory_address),
      .data_to_write (data_to_write_making_decision),
      .write_enable  (instruction_writing_to_memory && !halt),
      .memory_output (data_to_read)
    );

endmodule
