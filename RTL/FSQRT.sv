//=============================================================================+
//FSQRT
//choose ref point by exponent, then sqrt(exp) is easy (>>1)                                                            
//see: Floating-Point Division and Square Root using a
//Taylor-Series Expansion Algorithm
//by Taek-Jun Kwon, Jeff Sondeen, Jeff Draper                                                                              
//=============================================================================+


module FSQRT(
  input rst,  //this is to reset the states. should come on the same cycle as the clock
  input clk,

  input  logic [31 : 0] reg_orig,      // first operand
  input  logic valid,
  output logic halt,  //no ready bit, we just lower the halt (a reverse ready) 
  output logic [31 : 0]  reg_out  // the result of the calculation untill now
  );
  

  
	logic [31 : 0]  reg_pow; //this one rises
	logic [31 : 0]  reg_to_mul; //this one holds the thing to rise
	logic [31 : 0] iter;

  
  logic [31 : 0] y_0;
  logic [8:0] temp;
  logic [31 : 0] mul1_in_a;
  logic [31 : 0] mul1_in_b;
  logic [31 : 0] sub_out;
  
  logic [31 : 0] mul2_in_a;
  logic [31 : 0] mul2_in_b;
  
  logic [31 : 0] div_in_a;
  logic [31 : 0] div_in_b;


  logic [31 : 0] sub_in_b; 
  logic [31 : 0] sub_in_a;
  logic [31 : 0] final_res; 
  logic [31 : 0] mul1_out;
  logic [31 : 0] mul2_out;
  logic [31 : 0]  div_out;
  
  
  FMUL mul1(.first_operand(mul1_in_a), .second_operand(mul1_in_b), .calculation_output(mul1_out));
  FMUL mul2(.first_operand(mul2_in_a), .second_operand(mul2_in_b), .calculation_output(mul2_out));
  FDIV div(.first_operand(div_in_a), .second_operand(div_in_b), .calculation_output(div_out));  
  FSUB sub(.first_operand(sub_in_a), .second_operand(sub_in_b), .calculation_output(sub_out));
  
  
  
  
  assign temp = ({1'b0, reg_orig[30:23]}  + 9'd127) >> 1;

  
  assign y_0 = {reg_orig[31], temp[7:0], reg_orig[22:0]};

  parameter [31:0] one = 32'b00111111100000000000000000000000;
  parameter [31:0] half = 32'b00111111000000000000000000000000;
  parameter [31:0] eighth = 32'b00111110000000000000000000000000;
  parameter [31:0] sixteenth =32'b00111101100000000000000000000000;
  parameter [31:0] five_over_onetwentyeight = 32'b00111101001000000000000000000000;
  parameter [31:0] seven_over_twofiftysix = 32'b00111100111000000000000000000000;

  assign reg_out = final_res;
  
  
  always_ff @(posedge clk or posedge rst)
	begin
	  
	  if (rst == 1'b1) begin
		iter <= 0;
		halt <= 1'b0;
	  end

	  else if (valid & (iter == 0))  begin
		if (reg_orig[31]) begin
		   final_res <= '0;
		end	
		else begin
		iter <= iter + 1;
		final_res <= sub_out;
		reg_to_mul <= sub_out;
		reg_pow <= sub_out;
		halt <= 1'b1;
		end
	  end
	  
	  else if (iter == 1)  begin
		
		iter <= iter + 1;
		final_res <= sub_out;
		reg_pow <= mul2_out;
		
	  end
	  else if (iter == 2)  begin
		
		iter <= iter + 1;
		final_res <= sub_out;
		reg_pow <= mul2_out;
		
	  end
	  else if (iter == 3)  begin
		
		iter <= iter + 1;
		final_res <= sub_out;
		reg_pow <= mul2_out;
		
	  end
	  else if (iter == 4)  begin
		
		iter <= iter + 1;
		final_res <= sub_out;
		reg_pow <= mul2_out;
		
	  end
	  
	  else if (iter == 5)  begin
		
		iter <= iter + 1;
		final_res <= sub_out;
		reg_pow <= mul2_out;
		
	  end
	  else if (iter == 6)  begin	
		iter <= 0;
		final_res <= mul1_out;
		halt <= 1'b0;
	  end  
  end
  
  
  //logic [31:0] NC;
  
  always_comb
  begin

	case (iter)
	    
	0: begin
		 mul1_in_a = y_0;
		 mul1_in_b = y_0;
		 
		 mul2_in_a = '0;
		 mul2_in_b = '0;
		 //NC = mul2_out;
		 
		 div_in_a = reg_orig;
		 div_in_b = mul1_out;
		 
		 sub_in_a = one;
		 sub_in_b = div_out;
	end
	
	1: begin
		 mul1_in_a = half;
		 mul1_in_b = reg_to_mul;
		 
		 mul2_in_a = reg_to_mul;
		 mul2_in_b = reg_pow;
		 
		 div_in_a = '0;
		 div_in_b = '0;
		 //NC = div_out;
		 
		 sub_in_a = one;
		 sub_in_b = mul1_out;
	end
	
	2: begin
		 mul1_in_a = eighth;
		 mul1_in_b = reg_pow;
		 
		 mul2_in_a = reg_to_mul;
		 mul2_in_b = reg_pow;
		 
		 div_in_a = '0;
		 div_in_b = '0;
		 //NC = div_out;
		 
		 sub_in_a = final_res;
		 sub_in_b = mul1_out;
	end
	
	3: begin
		 mul1_in_a = sixteenth;
		 mul1_in_b = reg_pow;
		 
		 mul2_in_a = reg_to_mul;
		 mul2_in_b = reg_pow;
		 
		 div_in_a = '0;
		 div_in_b = '0;
		 //NC = div_out;
		 
		 sub_in_a = final_res;
		 sub_in_b = mul1_out;
	end

	4: begin
		 mul1_in_a = five_over_onetwentyeight;
		 mul1_in_b = reg_pow;
		 
		 mul2_in_a = reg_to_mul;
		 mul2_in_b = reg_pow;
		 
		 div_in_a = '0;
		 div_in_b = '0;
		 //NC = div_out;
		 
		 sub_in_a = final_res;
		 sub_in_b = mul1_out;
	end
	
	
	5: begin
		 mul1_in_a = seven_over_twofiftysix;
		 mul1_in_b = reg_pow;
		 
		 mul2_in_a = reg_to_mul;
		 mul2_in_b = reg_pow;
		 
		 div_in_a = '0;
		 div_in_b = '0;
		 //NC = div_out;
		 
		 sub_in_a = final_res;
		 sub_in_b = mul1_out;
	end
	
	6: begin  //we can instead use the divider for the final multiplication, but whatever.
		 mul1_in_a = final_res;
		 mul1_in_b = y_0;
		 
		 mul2_in_a = '0;
		 mul2_in_b = '0;
		 
		 div_in_a = '0;
		 div_in_b = '0;
		 //NC = div_out;
		 
		 sub_in_a = '0;
		 sub_in_b = '0;
	end
	
	
    default: begin
       mul1_in_a = '0;
		 mul1_in_b = '0;
		 
		 mul2_in_a = '0;
		 mul2_in_b = '0;
		 
		 div_in_a = '0;
		 div_in_b = '0;
		 
		 sub_in_a = '0;
		 sub_in_b = '0;
		
    end

  endcase
  end
  
  endmodule