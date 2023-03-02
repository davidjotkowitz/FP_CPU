//=============================================================================+
// RISC-V Top Module : the top level of the risc-v processor, connects all the |
//                     relevant modules to get it functioning as specified.    |
//                                                                             |
//=============================================================================+

module RISC_V_Top_FP(
    input logic clk,
    input logic reset
);

    logic halt, halt_sqrt;
	 logic [7 : 0] address_of_branch, address_to_return_from_JAL;
    logic taken_branch, flush_connect, address_to_return_from_JAL_write_enable;
    logic [4 : 0] destination_reg_for_return_JAL_address;

    logic [31 : 0] ID_output_first_operand, ID_output_second_operand, ID_output_immediate_value;

    logic source_of_first_alu_operand_connect;
    logic source_of_second_alu_operand_connect;
    logic [2 : 0] kind_of_calculation_connect;
    logic calculate_logical_or_arithmetic_connect;
    logic [4 : 0] destination_register_connect;
    logic load_instruction_indicator_connect;
    logic store_instruction_indicator_connect;
    logic [2 : 0] FUNC3_of_load_store_instructions_connect;
    logic register_file_write_enable_connect;
    logic source_for_register_writing_ALU_or_MEM_connect;

    logic [31 : 0] execution_output;

    logic [31 : 0] memory_output_data, memory_output_forwarded_data_to_ID;

    logic writeBack_register_file_write_enable;
    logic [31 : 0] writeBack_register_file_write_value;
    logic [4 : 0] writeBack_register_file_write_destination;

    logic hazard_barnch_is_taken_indicator_connect, hazard_load_indicator_connect, found_hazard;

    logic [1 : 0] ID_first_source_register_forwarding_point, ID_second_source_register_forwarding_point;
    logic [1 : 0] EXE_first_source_register_forwarding_point, EXE_second_source_register_forwarding_point;

    logic [31 : 0] instruction, pc;

    // Instruction Fetch Stage:
    Instruction_Fetch_FP IF_instance (
        .clk                        (clk),
        .reset                      (reset),
        .hazard_load_indicator      (hazard_load_indicator_connect),
        .branched_address_indicator (taken_branch),
        .address_to_branch          (address_of_branch),
        .instruction                (instruction),
        .pc                         (pc),
		  .halt								(halt)
    );

    logic [31 : 0] instruction_to_ID, pc_to_ID;

    always_ff @(posedge clk)
    if(reset) begin
        instruction_to_ID <= '0;
        pc_to_ID <= '0;
    end
    else if(!hazard_load_indicator_connect) begin
        instruction_to_ID <= instruction;
        pc_to_ID <= pc;
    end

    // Instruction Decode Stage:
    Branch_Resolution_Unit BRU_instance (
        .clk                     (clk),
        .reset                   (reset),
        .pc                      (pc_to_ID),
        .instruction             (instruction_to_ID),
        .first_operand           (ID_output_first_operand), //from decoder
        .second_operand          (ID_output_second_operand), //from decoder
        .the_branch_is_taken     (taken_branch),
        .address_to_branch       (address_of_branch),
        .retrun_address_from_JAL (address_to_return_from_JAL),
        .retrun_address_usage    (address_to_return_from_JAL_write_enable),
        .retrun_address_reg      (destination_reg_for_return_JAL_address),
        .flush_indicator         (flush_connect)
    );


    logic [4 : 0] first_source_register_in_ID, second_source_register_in_ID;
    assign first_source_register_in_ID = instruction_to_ID[19 : 15];
    assign second_source_register_in_ID = instruction_to_ID[24 : 20];

    logic          source_of_first_alu_operand_connect_ID;
    logic          source_of_second_alu_operand_connect_ID;
    logic [2  : 0] kind_of_calculation_connect_ID;
    logic          calculate_logical_or_arithmetic_connect_ID;
    logic [4  : 0] destination_register_connect_ID;
    logic          load_instruction_indicator_connect_ID;
    logic          store_instruction_indicator_connect_ID;
    logic [2  : 0] FUNC3_of_load_store_instructions_connect_ID;
    logic          register_file_write_enable_connect_ID;
    logic          source_for_register_writing_ALU_or_MEM_connect_ID;

    Hazard_Detection_Unit HDU_instance (
        .load_instruction_in_EXEStage                  (load_instruction_indicator_connect_ID), //instruction in EX is load
        .destination_register_of_EXeStage_instruction  (destination_register_connect_ID), //instruction in EX rd
        .first_source_register_of_IDStage_instruction  (first_source_register_in_ID), //
        .second_source_register_of_IDStage_instruction (second_source_register_in_ID),
        .the_branch_is_taken                           (taken_branch),
        .hazard_barnch_is_taken_indicator              (hazard_barnch_is_taken_indicator_connect),
        .hazard_load_instruction_indicator             (hazard_load_indicator_connect)
    );


    assign found_hazard = (hazard_barnch_is_taken_indicator_connect || hazard_load_indicator_connect);

    Instruction_Decode_FP ID_instance (
        .clk                       (clk),
        .reset                     (reset),
        .instruction               (instruction_to_ID),
        .forward_source_for_rs1    (ID_first_source_register_forwarding_point), //from forwarding unit
        .forward_source_for_rs2    (ID_second_source_register_forwarding_point),
        .forwarded_result_from_ALU (execution_output), //alu result
        .forwarded_result_from_Mem (memory_output_forwarded_data_to_ID),
        .return_address_JAL        (address_to_return_from_JAL_write_enable),
        .return_address_reg        (destination_reg_for_return_JAL_address),
        .return_address            (address_to_return_from_JAL),
        .register_write_enable     (writeBack_register_file_write_enable), //from WB stage
        .destination_register      (writeBack_register_file_write_destination),
        .value_to_write_to_reg     (writeBack_register_file_write_value),
        .first_operand_value       (ID_output_first_operand),
        .second_operand_value      (ID_output_second_operand),
        //.immediate_value           (ID_output_immediate_value),
		  .halt							  (halt)
    );

    Control_Unit_FP CU_instance (
        .instruction                            (instruction_to_ID),
        .source_of_first_alu_operand            (source_of_first_alu_operand_connect),
        .source_of_second_alu_operand           (source_of_second_alu_operand_connect),
        .kind_of_calculation                    (kind_of_calculation_connect),
        .calculate_logical_or_arithmetic        (calculate_logical_or_arithmetic_connect),
        .destination_register                   (destination_register_connect),
        .load_instruction_indicator             (load_instruction_indicator_connect),
        .store_instruction_indicator            (store_instruction_indicator_connect),
        .FUNC3_of_load_store_instructions       (FUNC3_of_load_store_instructions_connect),
        .register_file_write_enable             (register_file_write_enable_connect),
        .source_for_register_writing_ALU_or_MEM (source_for_register_writing_ALU_or_MEM_connect),
		  .halt_sqrt										(halt_sqrt),
		  .halt_out											(halt)
		  
    );

    logic [31 : 0] instruction_to_EXE;
    logic [31 : 0] pc_to_EXE;
    logic [31 : 0] first_operand_to_EXE;
    logic [31 : 0] second_operand_to_EXE;
    logic [31 : 0] immediate_value_to_EXE;

    logic flush_EXE_connect;

    always_ff @(posedge clk)
    if(reset) begin
        instruction_to_EXE <= '0;
        pc_to_EXE <= '0;
        first_operand_to_EXE <= '0;
        second_operand_to_EXE <= '0;
        immediate_value_to_EXE <= '0;

        source_of_first_alu_operand_connect_ID <= '0;
        source_of_second_alu_operand_connect_ID <= '0;
        kind_of_calculation_connect_ID <= '0;
        calculate_logical_or_arithmetic_connect_ID <= '0;
        destination_register_connect_ID <= '0;
        load_instruction_indicator_connect_ID <= '0;
        store_instruction_indicator_connect_ID <= '0;
        FUNC3_of_load_store_instructions_connect_ID <= '0;
        register_file_write_enable_connect_ID <= '0;
        source_for_register_writing_ALU_or_MEM_connect_ID <= '0;
        flush_EXE_connect <= '0;
    end
    else begin
        instruction_to_EXE <= instruction_to_ID;
        pc_to_EXE <= pc_to_ID;
        first_operand_to_EXE <= ID_output_first_operand;
        second_operand_to_EXE <= ID_output_second_operand;
        immediate_value_to_EXE <= ID_output_immediate_value;
        flush_EXE_connect <= flush_connect;

        if(found_hazard || flush_EXE_connect) begin
          source_of_first_alu_operand_connect_ID <= '0;
          source_of_second_alu_operand_connect_ID <= '0;
          kind_of_calculation_connect_ID <= '0;
          calculate_logical_or_arithmetic_connect_ID <= '0;
          destination_register_connect_ID <= '0;
          load_instruction_indicator_connect_ID <= '0;
          store_instruction_indicator_connect_ID <= '0;
          FUNC3_of_load_store_instructions_connect_ID <= '0;
          register_file_write_enable_connect_ID <= '0;
          source_for_register_writing_ALU_or_MEM_connect_ID <= '0;
        end
        else begin
          source_of_first_alu_operand_connect_ID <= source_of_first_alu_operand_connect;
          source_of_second_alu_operand_connect_ID <= source_of_second_alu_operand_connect;
          kind_of_calculation_connect_ID <= kind_of_calculation_connect;
          calculate_logical_or_arithmetic_connect_ID <= calculate_logical_or_arithmetic_connect;
          destination_register_connect_ID <= destination_register_connect;
          load_instruction_indicator_connect_ID <= load_instruction_indicator_connect;
          store_instruction_indicator_connect_ID <= store_instruction_indicator_connect;
          FUNC3_of_load_store_instructions_connect_ID <= FUNC3_of_load_store_instructions_connect;
          register_file_write_enable_connect_ID <= register_file_write_enable_connect;
          source_for_register_writing_ALU_or_MEM_connect_ID <= source_for_register_writing_ALU_or_MEM_connect;
        end
    end


    logic [31 : 0] second_operand_to_MEM;
    logic source_of_first_alu_operand_connect_EXE;
    logic source_of_second_alu_operand_connect_EXE;
    logic [2 : 0] kind_of_calculation_connect_EXE;
    logic calculate_logical_or_arithmetic_connect_EXE;
    logic [4 : 0] destination_register_connect_EXE;
    logic load_instruction_indicator_connect_EXE;
    logic store_instruction_indicator_connect_EXE;
    logic [2 : 0] FUNC3_of_load_store_instructions_connect_EXE;
    logic register_file_write_enable_connect_EXE;
    logic source_for_register_writing_ALU_or_MEM_connect_EXE;
    logic [31 : 0] execution_output_to_MEM;

    // Execution Stage
    Execution_Unit_FP EXEU_instance (
        .clk                                    (clk),
        .reset                                  (reset),
        .instruction                            (instruction_to_EXE),
        .source_of_first_alu_operand            (source_of_first_alu_operand_connect_ID),
        .source_of_second_alu_operand           (source_of_second_alu_operand_connect_ID),
        .kind_of_calculation                    (kind_of_calculation_connect_ID),
        .calculate_logical_or_arithmetic        (calculate_logical_or_arithmetic_connect_ID),
        .destination_register                   (destination_register_connect_ID),
        .load_instruction_indicator             (load_instruction_indicator_connect_ID),
        .store_instruction_indicator            (store_instruction_indicator_connect_ID),
        .FUNC3_of_load_store_instructions       (FUNC3_of_load_store_instructions_connect_ID),
        .register_file_write_enable             (register_file_write_enable_connect_ID),
        .source_for_register_writing_ALU_or_MEM (source_for_register_writing_ALU_or_MEM_connect_ID),
        .first_operand_of_instruction           (first_operand_to_EXE),
        .second_operand_of_instruction          (second_operand_to_EXE),
        .immediate_value                        (immediate_value_to_EXE),
        .pc                                     (pc_to_EXE),
        .forward_of_ALU_or_mem_to_rs1           (EXE_first_source_register_forwarding_point), //from forwarding unit
        .forward_of_ALU_or_mem_to_rs2           (EXE_second_source_register_forwarding_point),
        .forwarded_data_from_MemStage           (execution_output_to_MEM), //from intermediate reg ex_mem
        .forwarded_data_from_writeBackStage     (writeBack_register_file_write_value), //from intermediate reg mem_wb
        .execution_output                       (execution_output),
		  .halt_sqrt										(halt_sqrt)
    );


    always_ff @(posedge clk)
    if(reset) begin
        second_operand_to_MEM <= '0;
        source_of_first_alu_operand_connect_EXE <= '0;
        source_of_second_alu_operand_connect_EXE <= '0;
        kind_of_calculation_connect_EXE <= '0;
        calculate_logical_or_arithmetic_connect_EXE <= '0;
        destination_register_connect_EXE <= '0;
        load_instruction_indicator_connect_EXE <= '0;
        store_instruction_indicator_connect_EXE <= '0;
        FUNC3_of_load_store_instructions_connect_EXE <= '0;
        register_file_write_enable_connect_EXE <= '0;
        source_for_register_writing_ALU_or_MEM_connect_EXE <= '0;
        execution_output_to_MEM <= '0;
    end
    else begin
        second_operand_to_MEM <= second_operand_to_EXE;
        source_of_first_alu_operand_connect_EXE <= source_of_first_alu_operand_connect_ID;
        source_of_second_alu_operand_connect_EXE <= source_of_second_alu_operand_connect_ID;
        kind_of_calculation_connect_EXE <= kind_of_calculation_connect_ID;
        calculate_logical_or_arithmetic_connect_EXE <= calculate_logical_or_arithmetic_connect_ID;
        destination_register_connect_EXE <= destination_register_connect_ID;
        load_instruction_indicator_connect_EXE <= load_instruction_indicator_connect_ID;
        store_instruction_indicator_connect_EXE <= store_instruction_indicator_connect_ID;
        FUNC3_of_load_store_instructions_connect_EXE <= FUNC3_of_load_store_instructions_connect_ID;
        register_file_write_enable_connect_EXE <= register_file_write_enable_connect_ID;
        source_for_register_writing_ALU_or_MEM_connect_EXE <= source_for_register_writing_ALU_or_MEM_connect_ID;
        execution_output_to_MEM <= execution_output;
    end

    // Memory Stage:
    Memory_Unit_FP MEMU_instance (
        .clk                           (clk),
        .reset                         (reset),
        .instruction_writing_to_memory (store_instruction_indicator_connect_EXE), //write to mem
        .data_to_write                 (second_operand_to_MEM), //wr data, ID_output_second_operand
        .memory_address                (execution_output_to_MEM[7 : 0]), //ALU calculates  address
        .load_store_instructions_FUNC3 (FUNC3_of_load_store_instructions_connect_EXE),
        .memory_output                 (memory_output_data)
    );

    assign memory_output_forwarded_data_to_ID = (load_instruction_indicator_connect_EXE) ? memory_output_data : execution_output_to_MEM ;

    logic source_of_first_alu_operand_connect_MEM;
    logic source_of_second_alu_operand_connect_MEM;
    logic [2 : 0] kind_of_calculation_connect_MEM;
    logic calculate_logical_or_arithmetic_connect_MEM;
    logic [4 : 0] destination_register_connect_MEM;
    logic load_instruction_indicator_connect_MEM;
    logic store_instruction_indicator_connect_MEM;
    logic [2 : 0] FUNC3_of_load_store_instructions_connect_MEM;
    logic register_file_write_enable_connect_MEM;
    logic source_for_register_writing_ALU_or_MEM_connect_MEM;
    logic [31 : 0] memory_output_data_to_WB;
    logic [31 : 0] execution_output_to_WB;
    always_ff @(posedge clk)
    if(reset) begin
        source_of_first_alu_operand_connect_MEM <= '0;
        source_of_second_alu_operand_connect_MEM <= '0;
        kind_of_calculation_connect_MEM <= '0;
        calculate_logical_or_arithmetic_connect_MEM <= '0;
        destination_register_connect_MEM <= '0;
        load_instruction_indicator_connect_MEM <= '0;
        store_instruction_indicator_connect_MEM <= '0;
        FUNC3_of_load_store_instructions_connect_MEM <= '0;
        register_file_write_enable_connect_MEM <= '0;
        source_for_register_writing_ALU_or_MEM_connect_MEM <= '0;
        memory_output_data_to_WB     <= '0;
        execution_output_to_WB     <= '0;
    end
    else begin
        source_of_first_alu_operand_connect_MEM <= source_of_first_alu_operand_connect_EXE;
        source_of_second_alu_operand_connect_MEM <= source_of_second_alu_operand_connect_EXE;
        kind_of_calculation_connect_MEM <= kind_of_calculation_connect_EXE;
        calculate_logical_or_arithmetic_connect_MEM <= calculate_logical_or_arithmetic_connect_EXE;
        destination_register_connect_MEM <= destination_register_connect_EXE;
        load_instruction_indicator_connect_MEM <= load_instruction_indicator_connect_EXE;
        store_instruction_indicator_connect_MEM <= store_instruction_indicator_connect_EXE;
        FUNC3_of_load_store_instructions_connect_MEM <= FUNC3_of_load_store_instructions_connect_EXE;
        register_file_write_enable_connect_MEM <= register_file_write_enable_connect_EXE;
        source_for_register_writing_ALU_or_MEM_connect_MEM <= source_for_register_writing_ALU_or_MEM_connect_EXE;
        memory_output_data_to_WB <= memory_output_data;
        execution_output_to_WB <= execution_output_to_MEM;
    end


    // Writeback Stage:
    assign writeBack_register_file_write_value = (source_for_register_writing_ALU_or_MEM_connect_MEM) ? memory_output_data_to_WB : execution_output_to_WB;
    assign writeBack_register_file_write_enable = register_file_write_enable_connect_MEM;
    assign writeBack_register_file_write_destination = destination_register_connect_MEM;


    // Forwarding Unit:
    Forwarding_Unit FU_instance (
        .executionStage_instruction_writing_to_rf_indicator  (register_file_write_enable_connect_ID),
        .memStage_instruction_writing_to_rf_indicator        (register_file_write_enable_connect_EXE),
        .writeBackStage_instruction_writing_to_rf_indicator  (register_file_write_enable_connect_MEM),
        .destination_register_in_executionStage              (destination_register_connect_ID),
        .destination_register_in_memStage                    (destination_register_connect_EXE),
        .destination_register_in_writeBackStage              (destination_register_connect_MEM),
        .first_source_register_in_IDStage                    (instruction_to_ID[19 : 15]),
        .second_source_register_in_IDStage                   (instruction_to_ID[24 : 20]),
        .first_source_register_in_executionStage             (instruction_to_EXE[19 : 15]),
        .second_source_register_in_executionStage            (instruction_to_EXE[24 : 20]),
        .forwarded_data_source_for_rs1_in_IDStage            (ID_first_source_register_forwarding_point),
        .forwarded_data_source_for_rs2_in_IDStage            (ID_second_source_register_forwarding_point),
        .forwarded_data_source_for_rs1_in_EXEStage           (EXE_first_source_register_forwarding_point),
        .forwarded_data_source_for_rs2_in_EXEStage           (EXE_second_source_register_forwarding_point)
    );

endmodule
