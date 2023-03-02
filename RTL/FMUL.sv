//=============================================================================+
//FMUL
//                                                                             |
//                                                                             |
//=============================================================================+


module FMUL(
  input  logic [31 : 0] first_operand,      // first operand
  input  logic [31 : 0] second_operand,     // second operand
  output logic [31 : 0] calculation_output     // the result of the calculation
  );
  logic [47 : 0] mult_output; ///two 24 bit long mult can get up to 48 bits
  logic [24 : 0] mul_tmp_mantisa; ///the 24'th bit is for overflow detection
  logic [8 : 0] mul_tmp_exp;


    always_comb
    begin
		if(first_operand[30 : 0] == {31{1'b0}})
			begin
			calculation_output [30:0]= {31{1'b0}};
			calculation_output[31] = first_operand[31]^second_operand[31];
			mul_tmp_mantisa = {25{1'b0}};
			mul_tmp_exp = {9{1'b0}};
			mult_output = {48{1'b0}};
			end
		else if(second_operand[30 : 0] == {31{1'b0}})
			begin
			calculation_output [30:0]= {31{1'b0}};
			calculation_output[31] = first_operand[31]^second_operand[31];
			mul_tmp_mantisa = {25{1'b0}};
			mul_tmp_exp = {9{1'b0}};
			mult_output = {48{1'b0}};
			end
		else //first, calculate the mantisa multiplication, later everything else.
			begin
			mult_output = {1'b1, first_operand[22:0]}*{1'b1, second_operand[22:0]};
			mul_tmp_mantisa = mult_output[47:23];
			mul_tmp_exp = {1'b0, first_operand[30:23]}+{1'b0, second_operand[30:23]}-9'd127;
			
			if({1'b0, first_operand[30:23]}+{1'b0, second_operand[30:23]} < 9'd127/*div_tmp_exp_first == 9{1'b0}*/)//underflow
				begin
				calculation_output[30:0] = {(31){1'b0}};
				calculation_output[31] = first_operand[31]^second_operand[31];
				end
			
			else if(mul_tmp_exp[8])
				begin
				calculation_output[30:0] = {(31){1'b1}};
				calculation_output[31] = first_operand[31]^second_operand[31];
				end
			
			else
				begin
				calculation_output[31] = first_operand[31]^second_operand[31];
				if(mul_tmp_mantisa[24])//overflow
					begin
					calculation_output[30:0] = {mul_tmp_exp+1, mul_tmp_mantisa[23:1]};
					end
				else if((!mul_tmp_mantisa[24])&&(!mul_tmp_mantisa[23]))//underflow, probably not needed
					begin
					calculation_output[30:0] = {mul_tmp_exp-1, mul_tmp_mantisa[22:0]};
					end
				else//no overflow, no underflow
					begin
					calculation_output[30:0] = {mul_tmp_exp, mul_tmp_mantisa[22:0]};
					end
				end
			end
    end

endmodule