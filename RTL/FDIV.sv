//=============================================================================+
//FDIV
//                                                                             |
//                                                                             |
//=============================================================================+


module FDIV(
  input  logic [31 : 0] first_operand,      // first operand
  input  logic [31 : 0] second_operand,     // second operand
  output logic [31 : 0] calculation_output     // the result of the calculation
  );
  logic [47 : 0] div_tmp_mantisa; ///the 24'th bit is for underflow detection
  logic [8 : 0] div_tmp_exp_first;
  logic [7 : 0] div_tmp_exp_second;


    always_comb
    begin
		if(first_operand[30 : 0] == {31{1'b0}})
			begin
			calculation_output [30:0]= {31{1'b0}};
			calculation_output[31] = first_operand[31]^second_operand[31];
			div_tmp_mantisa = '0;
			div_tmp_exp_first = {9{1'b0}};
			div_tmp_exp_second = {8{1'b0}};
			///div_output = {48{1'b0}};
			end
		else if(second_operand[30 : 0] == {31{1'b0}})///TODO: exception, div by 0
			begin
			calculation_output = 'z;
			div_tmp_mantisa = '0;
			div_tmp_exp_first = {9{1'b0}};
			div_tmp_exp_second = {8{1'b0}};
			///div_output = {48{1'b0}};
			end
		else //first, calculate the mantisa multiplication, later everything else.
			begin
			div_tmp_mantisa = {1'b1, first_operand[22:0], {24{1'b0}}}/{{24{1'b0}}, 1'b1, second_operand[22:0]};
			div_tmp_exp_first = {1'b0, first_operand[30:23]}+9'd127-{1'b0, second_operand[30:23]};
			
			div_tmp_exp_second = div_tmp_exp_first[7 : 0];
			
			if({1'b0, second_operand[30:23]} > (9'd127+{1'b0, first_operand[30:23]}))//underflow
				begin
				calculation_output [30:0]= {31{1'b0}};
				calculation_output[31] = first_operand[31]^second_operand[31];
				end
				
			else if(div_tmp_exp_first[8])
				begin
				calculation_output[30:0] = {(31){1'b1}};
				calculation_output[31] = first_operand[31]^second_operand[31];				end
			else
				begin
				
				if(!div_tmp_mantisa[24])//underflow
					begin
					calculation_output[30:0] = {div_tmp_exp_second-8'd1, div_tmp_mantisa[22:0]};
					calculation_output[31] = first_operand[31]^second_operand[31];
					end
				else//no overflow, no underflow
					begin
					calculation_output[30:0] = {div_tmp_exp_second, div_tmp_mantisa[23:1]};
					calculation_output[31] = first_operand[31]^second_operand[31];
					end
				end
			end
    end

endmodule