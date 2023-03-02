//=============================================================================+
//FSUB
//                                                                             |
//                                                                             |
//=============================================================================+


module FSUB(
  input  logic [31 : 0] first_operand,      // first operand
  input  logic [31 : 0] second_operand,     // second operand
  output logic [31 : 0] calculation_output     // the result of the calculation 
   );
  logic [31 : 0] second_operand_n;
  assign  second_operand_n = {~second_operand[31], second_operand[30:0]};
  
  FADD add_flipped (.first_operand(first_operand),
  .second_operand(second_operand_n),
  .calculation_output(calculation_output)
  );
endmodule