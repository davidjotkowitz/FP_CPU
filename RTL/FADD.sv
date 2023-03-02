//=============================================================================+
//FADD
//                                                                             |
//                                                                             |
//=============================================================================+


module FADD(
  input  logic [31 : 0] first_operand,      // first operand
  input  logic [31 : 0] second_operand,     // second operand
  output logic [31 : 0] calculation_output     // the result of the calculation
 );
 /*
  
  output logic [25 : 0] mantissa_out_temp, //the 25'th bit- mantisa overflow detection, the 24'th bit- for appending the "1" to the matissa, the 0'th bit- for underflow detection
  output logic [25 : 0] mantissa_min_tot,
  output logic [25 : 0] mantissa_max_tot,
  output logic [7 : 0] point_shift,

  
  output logic [22:0] mantissa_out,
  output logic [7 : 0] exp_out,
  output logic sign_out,
  
  output logic [31 : 0] reg_min,
  output logic [31 : 0] reg_max
  
 );
  */
  logic [25 : 0] mantissa_out_temp; //the 25'th bit- mantisa overflow detection, the 24'th bit- for appending the "1" to the matissa, the 0'th bit- for underflow detection
  logic [25 : 0] mantissa_min_tot;
  logic [25 : 0] mantissa_max_tot;
  logic [7 : 0] point_shift;


  logic [22:0] mantissa_out;
  logic [7 : 0] exp_out;
  logic sign_out;
  
  logic [31 : 0] reg_min;
  logic [31 : 0] reg_max;

	always_comb begin
		
		if(first_operand[30 : 0] == {31{1'b0}}) begin
			mantissa_out_temp = '0;
			mantissa_min_tot = '0;
			mantissa_max_tot = '0;
			point_shift = '0;
			reg_max = '0;
			reg_min = '0;
			
			mantissa_out = second_operand[22 : 0];
			exp_out = second_operand[30 : 23];
			sign_out = second_operand[31];
		end
		
		
		else if(second_operand[30 : 0] == {31{1'b0}}) begin
			mantissa_out_temp = '0;
			mantissa_min_tot = '0;
			mantissa_max_tot = '0;
			point_shift = '0;
			reg_max = '0;
			reg_min = '0;
			
			mantissa_out = first_operand[22 : 0];
			exp_out = first_operand[30 : 23];
			sign_out = first_operand[31];
		end
		
		
		else begin
			
			if((first_operand[30:23]>second_operand[30:23])|((first_operand[30:23]==second_operand[30:23]) & (first_operand[22:0]>second_operand[22:0]))) begin 
				reg_max = first_operand;
				reg_min = second_operand;
			end
			else	begin
				reg_max = second_operand;
				reg_min = first_operand;
			end
				
			sign_out = reg_max[31];
			point_shift = reg_max[30:23]-reg_min[30:23];
			
			if (point_shift>23) begin
				mantissa_out_temp = '0;
				mantissa_min_tot = '0;
				mantissa_max_tot = '0;
				mantissa_out = reg_max[22 : 0];
				exp_out = reg_max[30 : 23];				
			end
			
			else begin
				mantissa_min_tot = {1'b0,{1'b1, reg_min[22:0], 1'b0}>>point_shift};
				mantissa_max_tot = {2'b01, reg_max[22:0],1'b0};
	 
				if (reg_max[31] == reg_min[31]) begin //addition
					mantissa_out_temp = mantissa_min_tot + mantissa_max_tot;
					
					if(mantissa_out_temp[25]) begin	//overflow- add to the exponent
						if (reg_max[30:23] == 8'hff) begin
							exp_out = 8'hff;
							mantissa_out = {23{1'b1}};
						end
						else begin
							exp_out = reg_max[30:23]+8'b1;
							mantissa_out = mantissa_out_temp[24 : 2];	//need to check if we took the right bits
						end
					end
					else begin
						exp_out = reg_max[30:23];
						mantissa_out = mantissa_out_temp[23 : 1];	//need to check if we took the right bits
					end
				end
				else begin //subtraction
					mantissa_out_temp = mantissa_max_tot - mantissa_min_tot;

					casez(mantissa_out_temp[24:0])
						default : begin
							exp_out = reg_max[30:23];
							mantissa_out = mantissa_out_temp[23 : 1];
						end
						25'b1????????????????????????: begin
							exp_out = reg_max[30:23];
							mantissa_out = mantissa_out_temp[23 : 1];
						end
						25'b01???????????????????????: begin 
							if (reg_max[30:23] < 8'd1) begin
								exp_out = 8'b0;
								mantissa_out = 22'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd1;
								mantissa_out = mantissa_out_temp[22:0]; 
							 end
						end
						25'b001??????????????????????: begin 
							if (reg_max[30:23] < 8'd2) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd2;
								mantissa_out = {mantissa_out_temp[21:0], 1'b0}; 
							 end
						end
						25'b0001?????????????????????: begin 
							if (reg_max[30:23] < 8'd3) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd3;
								mantissa_out = {mantissa_out_temp[20:0], 2'b0}; 
							 end
						end
						25'b00001????????????????????: begin 
							if (reg_max[30:23] < 8'd4) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd4;
								mantissa_out = {mantissa_out_temp[19:0], 3'b0}; 
							 end
						end
						25'b000001???????????????????: begin 
							if (reg_max[30:23] < 8'd5) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd5;
								mantissa_out = {mantissa_out_temp[18:0], 4'b0}; 
							 end
						end
						25'b0000001??????????????????: begin 
							if (reg_max[30:23] < 8'd6) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd6;
								mantissa_out = {mantissa_out_temp[17:0], 5'b0}; 
							 end
						end
						25'b00000001?????????????????: begin 
							if (reg_max[30:23] < 8'd7) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd7;
								mantissa_out = {mantissa_out_temp[16:0], 6'b0}; 
							 end
						end
						25'b000000001????????????????: begin 
							if (reg_max[30:23] < 8'd8) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd8;
								mantissa_out = {mantissa_out_temp[15:0], 7'b0}; 
							 end
						end
						25'b0000000001???????????????: begin 
							if (reg_max[30:23] < 8'd9) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd9;
								mantissa_out = {mantissa_out_temp[14:0], 8'b0}; 
							 end
						end
						25'b00000000001??????????????: begin 
							if (reg_max[30:23] < 8'd10) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd10;
								mantissa_out = {mantissa_out_temp[13:0], 9'b0}; 
							 end
						end
						25'b000000000001?????????????: begin 
							if (reg_max[30:23] < 8'd11) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd11;
								mantissa_out = {mantissa_out_temp[12:0], 10'b0}; 
							 end
						end
						25'b0000000000001????????????: begin 
							if (reg_max[30:23] < 8'd12) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd12;
								mantissa_out = {mantissa_out_temp[11:0], 11'b0}; 
							 end
						end
						25'b00000000000001???????????: begin 
							if (reg_max[30:23] < 8'd13) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd13;
								mantissa_out = {mantissa_out_temp[10:0], 12'b0}; 
							 end
						end
						25'b000000000000001??????????: begin 
							if (reg_max[30:23] < 8'd14) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd14;
								mantissa_out = {mantissa_out_temp[9:0], 13'b0}; 
							 end
						end
						25'b0000000000000001?????????: begin 
							if (reg_max[30:23] < 8'd15) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd15;
								mantissa_out = {mantissa_out_temp[8:0], 14'b0}; 
							 end
						end
						25'b00000000000000001????????: begin 
							if (reg_max[30:23] < 8'd16) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd16;
								mantissa_out = {mantissa_out_temp[7:0], 15'b0}; 
							 end
						end
						25'b000000000000000001???????: begin 
							if (reg_max[30:23] < 8'd17) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd17;
								mantissa_out = {mantissa_out_temp[6:0], 16'b0}; 
							 end
						end
						25'b0000000000000000001??????: begin 
							if (reg_max[30:23] < 8'd18) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd18;
								mantissa_out = {mantissa_out_temp[5:0], 17'b0}; 
							 end
						end
						25'b00000000000000000001?????: begin 
							if (reg_max[30:23] < 8'd19) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd19;
								mantissa_out = {mantissa_out_temp[4:0], 18'b0}; 
							 end
						end
						25'b000000000000000000001????: begin 
							if (reg_max[30:23] < 8'd20) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd20;
								mantissa_out = {mantissa_out_temp[3:0], 19'b0}; 
							 end
						end
						25'b0000000000000000000001???: begin 
							if (reg_max[30:23] < 8'd21) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd21;
								mantissa_out = {mantissa_out_temp[2:0], 20'b0}; 
							 end
						end
						25'b00000000000000000000001??: begin 
							if (reg_max[30:23] < 8'd22) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd22;
								mantissa_out = {mantissa_out_temp[1:0], 21'b0}; 
							 end
						end
						25'b000000000000000000000001?: begin 
							if (reg_max[30:23] < 8'd23) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd23;
								mantissa_out = {mantissa_out_temp[0:0], 22'b0}; 
							 end
						end
						25'b0000000000000000000000001: begin 
							if (reg_max[30:23] < 8'd23) begin
								exp_out = 8'b0;
								mantissa_out = 23'b0;
							end
							else begin
								exp_out = reg_max[30:23] - 8'd23;
								mantissa_out = 23'b0; 
							 end
						end
						
						25'b000000000000000000000000: begin //special case: the arguments are the same with opposite sign bits
							exp_out = 8'b0;
							mantissa_out = 23'b0;
						end
					endcase
			   end
			end		
		end
		calculation_output = {sign_out, exp_out, mantissa_out};
	end

endmodule