//=============================================================================+
//FCMP
//check both equal and less_than (similar to min_max)
//	return by RM (with one of them or with 'or' of the two, depends)
//=============================================================================+

module FCMP(
  input  logic [31 : 0] first_operand,      // first operand
  input  logic [31 : 0] second_operand,     // second operand
  input  logic [2 : 0] RM,
  output logic [31 : 0] calculation_output     // the result of the calculation
  );
  ///logic common_sign;// 0 or 1, same as the format
  logic equal;
  logic less_than;

    always_comb
		begin
		if(first_operand[31 : 0]==second_operand[31 : 0])
			begin
			equal = 1'b1;
			end
		else
			begin
			equal = 1'b0;
			end
			
		
		if(first_operand[31] && !(second_operand[31]))//sign of the first is neg
			begin
			less_than = 1'b1;
			end
		else if (second_operand[31] && !(first_operand[31]))//sign of the second is neg
			begin
			less_than = 1'b0;
			end
		else if(first_operand[30:23]>second_operand[30:23])//exp in 1 is bigger
			begin
			less_than = first_operand[31];// if exp_1>exp_2, first_operand is smaller iff negative (sign=1)
			end
		else if(first_operand[30:23]<second_operand[30:23])//exp in 1 is smaller
			begin
			less_than = !first_operand[31];// if exp_1<exp_2, first_operand is smaller iff pos (sign=0)
			end
		//mant
		else if(first_operand[22:0]>second_operand[22:0])//mant in 1 is bigger
			begin
			less_than = first_operand[31];// if mant_1>mant_2, first_operand is smaller iff negative (sign=1)
			end
		else if(first_operand[22:0]<second_operand[22:0])//mant in 1 is smaller
			begin
			less_than = !first_operand[31];// if mant_1<mant_2, first_operand is smaller iff pos (sign=0)
			end
		else
			begin
			less_than = 1'b0;
			end
			
		
		///return res
		if(RM==3'b000)///LE (less/equal)
			begin
			calculation_output = {31'b0, (equal||less_than)};
			end
		else if(RM==3'b001)///LT(less than)
			begin
			calculation_output = {31'b0, less_than};
			end
		else ///(RM==3'b010)///EQ (equal)
			begin
			calculation_output = {31'b0, equal};
			end
		end
	
endmodule
