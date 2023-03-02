//=============================================================================+
// Data Memory Module : stores data used by the program in the cpu.            |
//                                                                             |
//                                                                             |
//=============================================================================+

module Data_Memory(
  input  logic          clk,
  input  logic          reset,
  input  logic [7  : 0] address,
  input  logic [31 : 0] data_to_write,
  input  logic          write_enable,
  output logic [31 : 0] memory_output
);

    logic [7 : 0] data_byte_num[256];
	 
	 /*
	 //test
	 assign data_byte_num[0] = 8'hff;
	 assign data_byte_num[1] = 8'hf0;
	 assign data_byte_num[2] = 8'h0f;
	 assign data_byte_num[3] = 8'hfb;
	 assign data_byte_num[4] = 8'haf;
	 assign data_byte_num[5] = 8'hab;
	 assign data_byte_num[6] = 8'hcd;
	 assign data_byte_num[7] = 8'h01;
	 assign data_byte_num[8] = 8'hff;
	 assign data_byte_num[9] = 8'hf0;
	 assign data_byte_num[10] = 8'h0f;
	 assign data_byte_num[11] = 8'hfb;
	 assign data_byte_num[12] = 8'haf;
	 assign data_byte_num[13] = 8'hab;
	 assign data_byte_num[14] = 8'hcd;
	 assign data_byte_num[15] = 8'h01;
	 assign data_byte_num[16] = 8'hff;
	 assign data_byte_num[17] = 8'hf0;
	 assign data_byte_num[18] = 8'h0f;
	 assign data_byte_num[19] = 8'hfb;
	 assign data_byte_num[20] = 8'haf;
	 assign data_byte_num[21] = 8'hab;
	 assign data_byte_num[22] = 8'hcd;
	 assign data_byte_num[23] = 8'h01;
	 */
/*
    always_comb
    begin
        
    end
*/

///bug in the old version by luai and marwa!!!!
    always_ff @(posedge clk)
		 if(write_enable)
		 begin
			  {data_byte_num[address+3], data_byte_num[address+2], data_byte_num[address+1], data_byte_num[address]} <= data_to_write;
		 end
		 
		 else
		 begin
			memory_output <= {data_byte_num[address+3], data_byte_num[address+2], data_byte_num[address+1], data_byte_num[address]};
		 end
endmodule
