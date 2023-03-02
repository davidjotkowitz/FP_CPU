//=============================================================================+
// Instructions Memory Module : holds the instructions of the program being    |
//                              processed.                                     |
//                                                                             |
//=============================================================================+

module Instructions_Memory_FP(
  input  logic [7  : 0] pc,
  output logic [31 : 0] instruction
);

    logic [7 : 0] instruction_byte_num[256];
	 
	 /*test
	 assign instruction_byte_num[0] = 8'hff;
	 assign instruction_byte_num[1] = 8'hf0;
	 assign instruction_byte_num[2] = 8'h0f;
	 assign instruction_byte_num[3] = 8'hfb;
	 assign instruction_byte_num[4] = 8'haf;
	 assign instruction_byte_num[5] = 8'hab;
	 assign instruction_byte_num[6] = 8'hcd;
	 assign instruction_byte_num[7] = 8'h01;
	 assign instruction_byte_num[8] = 8'hff;
	 assign instruction_byte_num[9] = 8'hf0;
	 assign instruction_byte_num[10] = 8'h0f;
	 assign instruction_byte_num[11] = 8'hfb;
	 assign instruction_byte_num[12] = 8'haf;
	 assign instruction_byte_num[13] = 8'hab;
	 assign instruction_byte_num[14] = 8'hcd;
	 assign instruction_byte_num[15] = 8'h01;
	 assign instruction_byte_num[16] = 8'hff;
	 assign instruction_byte_num[17] = 8'hf0;
	 assign instruction_byte_num[18] = 8'h0f;
	 assign instruction_byte_num[19] = 8'hfb;
	 assign instruction_byte_num[20] = 8'haf;
	 assign instruction_byte_num[21] = 8'hab;
	 assign instruction_byte_num[22] = 8'hcd;
	 assign instruction_byte_num[23] = 8'h01;
	 */

    assign instruction = {instruction_byte_num[pc+3], instruction_byte_num[pc+2], instruction_byte_num[pc+1], instruction_byte_num[pc]};

endmodule
