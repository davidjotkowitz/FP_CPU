//=============================================================================+
// Control Unit Module : outputs the control signals for every instruction     |
//                       being processed in the instruction descode stage.     |
//TODO: get the right op codes to our project.
//                                                                             |
//=============================================================================+

module Control_Unit_FP(
    input  logic [31 : 0] instruction,
	input  logic 		  halt_sqrt,
	//input  logic 		  halt_FMADD_FMSUB,
	
    output logic          source_of_first_alu_operand,
    output logic          source_of_second_alu_operand,
    output logic [2  : 0] kind_of_calculation,
    output logic          calculate_logical_or_arithmetic,
    output logic [4  : 0] destination_register,
    output logic          load_instruction_indicator,
    output logic          store_instruction_indicator,
    output logic [2  : 0] FUNC3_of_load_store_instructions,
    output logic          register_file_write_enable,
    output logic          source_for_register_writing_ALU_or_MEM,
	//TODO:
	//input  logic [2 : 0]  FSQRT_FSM_state,
	output logic		  halt_out//combine all halts
	//output logic 	      FSQRT_FSM_start
);

    logic [6 : 0] inst_tmp;
    assign inst_tmp = instruction[31 : 25];
	 assign halt_out = halt_sqrt;

    always_comb
    begin
	
        source_of_first_alu_operand = '0;
        source_of_second_alu_operand = '0;
        kind_of_calculation = '0;
        calculate_logical_or_arithmetic = '0;
        destination_register = '0;
        load_instruction_indicator = '0;
        store_instruction_indicator = '0;
        FUNC3_of_load_store_instructions = '0;
        register_file_write_enable = '0;
        source_for_register_writing_ALU_or_MEM = '0;
		  //FSQRT_FSM_start = '0;
		
		
		//halt_out = halt_sqrt||halt_FMADD_FMSUB;//  <-- add this if FMADD/SUB is needed: delete all comment before this

        case(instruction[31 : 25]) //opcode
			7'b0000000: //FADD
			begin
				source_of_first_alu_operand = 1'b1;
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
			end
			
			7'b0001011: //FSQRT
			begin
				source_of_first_alu_operand = 1'b1;
                ///source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
				/*
				if(FSQRT_FSM_state == 3'b000)
				begin
					FSQRT_FSM_start = 1'b1;
				end
				*/
			end
			
			7'b0000001: //FSUB
				begin
				source_of_first_alu_operand = 1'b1;
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
				end
				
			7'b0000010: //FMUL
				begin
				source_of_first_alu_operand = 1'b1;
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
				end
			7'b0000011: //FDIV
				begin
				source_of_first_alu_operand = 1'b1;
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
				end
				
			7'b0010100: //FMIN-MAX
				begin
				source_of_first_alu_operand = 1'b1;
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
				end
			7'b1010000: //FCMP
				begin
				source_of_first_alu_operand = 1'b1;
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
				end
            /*7'b0110111: //LUI
            begin
                source_of_first_alu_operand = 1'b1;
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
            end

            7'b0010111: //AUIPC
            begin
                source_of_first_alu_operand = 1'b1;
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 :7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
            end

            7'b0000011: //LOAD
            begin
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[11 : 7];
                load_instruction_indicator = 1'b1;
                FUNC3_of_load_store_instructions = instruction[14 : 12];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b1;
            end

            7'b0100011: //STYPE
            begin
                source_of_second_alu_operand = 1'b1;
                destination_register = instruction[24 : 20];
                store_instruction_indicator = 1'b1;
                FUNC3_of_load_store_instructions = instruction[14: 12];
            end

            7'b0010011: //ITYPE
            begin
                source_of_second_alu_operand = 1'b1;
                kind_of_calculation = instruction[14 : 12];
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
                calculate_logical_or_arithmetic = inst_tmp[5];
            end

            7'b0110011: // RTYPE
            begin
                kind_of_calculation = instruction[14 : 12];
                destination_register = instruction[11 : 7];
                register_file_write_enable = 1'b1;
                source_for_register_writing_ALU_or_MEM = 1'b0;
                calculate_logical_or_arithmetic = |(instruction[31 : 25]);
            end
			*/
        endcase
    end

endmodule
