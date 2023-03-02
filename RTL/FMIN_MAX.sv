//=============================================================================+
//FMIN-MAX
//first, check for sign diff
//if same sign:
//	check exp diff (beware of neg sign!)
//	if same exp:
//		check mantisa diff (beware of neg sign!)
//return                                                                             |
//                                                                             |
//=============================================================================+
module FMIN_MAX(
  input  logic [31 : 0] first_operand,      // first operand
  input  logic [31 : 0] second_operand,     // second operand
  input  logic [2 : 0] RM,
  output logic [31 : 0] calculation_output     // the result of the calculation
  );
  logic common_sign;// 0 or 1, same as the format
  logic [31 : 0] max;
  logic [31 : 0] min;

    always_comb
    begin
		//diff sign
		if(first_operand[31] && !(second_operand[31])) //first_operand is neg, second_operand is pos
			begin
			max = second_operand[31:0];
			min = first_operand[31:0];
			end
		else if(second_operand[31] && !(first_operand[31])) //second_operand is neg, first_operand is pos
			begin
			min = second_operand[31:0];
			max = first_operand[31:0];
			end
		///same sign
		else if (!(first_operand[31]) && !(second_operand[31]))/// both pos
			begin
			if(first_operand[30:23]==second_operand[30:23])//same exp
				begin
				if (first_operand[22:0]>second_operand[22:0])
					begin
					min = second_operand[31:0];
					max = first_operand[31:0];
					end
				else//if they are equal, it is still fine
					begin
					max = second_operand[31:0];
					min = first_operand[31:0];
					end
				end
			else if(first_operand[30:23]>second_operand[30:23])/// determine by exp
				begin
				min = second_operand[31:0];
				max = first_operand[31:0];
				end
			else
				begin
				max = second_operand[31:0];
				min = first_operand[31:0];
				end
			end
		else///both neg
			begin
			if(first_operand[30:23]==second_operand[30:23])//same exp
				begin
				if (first_operand[22:0]>second_operand[22:0])
					begin
					max = second_operand[31:0];
					min = first_operand[31:0];
					end
				else//if they are equal, it is still fine
					begin
					min = second_operand[31:0];
					max = first_operand[31:0];
					end
				end
			else if(first_operand[30:23]>second_operand[30:23])/// determine by exp
				begin
				max = second_operand[31:0];
				min = first_operand[31:0];
				end
			else
				begin
				min = second_operand[31:0];
				max = first_operand[31:0];
				end
			end
			
			
		if(RM==3'b000)///min
			begin
			calculation_output = min;
			end
		else ///(RM==3'b001)///max
			begin
			calculation_output = max;
			end
			
    end

endmodule