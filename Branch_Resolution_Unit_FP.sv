//=============================================================================+
// Branch Resolution Unit Module : decides regarding every branch and jump     |
//                                 instruction its direction and destination.  |
//                                                                             |
//=============================================================================+

module Branch_Resolution_Unit(
    input  logic          clk,
    input  logic          reset,
    input  logic [31 : 0] pc,
    input  logic [31 : 0] instruction,
    input  logic [31 : 0] first_operand,
    input  logic [31 : 0] second_operand,
    output logic          the_branch_is_taken,
    output logic [7  : 0] address_to_branch,
    output logic [7  : 0] retrun_address_from_JAL,
    output logic          retrun_address_usage,
    output logic [4  : 0] retrun_address_reg,
    output logic          flush_indicator
);

    logic   [20:0]  offset_of_JTYPE_instrctions;
    assign offset_of_JTYPE_instrctions = {instruction[31], instruction[19 : 12], instruction[20], instruction[30 : 21], 1'b0};

    logic   [11:0]  offset_of_ITYPE_instrctions;
    assign offset_of_ITYPE_instrctions = instruction[31 : 20];

    logic   [12:0]  immediate_value_of_BTYPE_instructions;
    assign immediate_value_of_BTYPE_instructions = {instruction[31], instruction[7], instruction[30 : 25], instruction[11 : 8], 1'b0};

    always_comb
    begin
        the_branch_is_taken = '0;
        address_to_branch = '0;
        retrun_address_from_JAL = '0;
        retrun_address_usage = '0;
        retrun_address_reg = '0;
        flush_indicator = '0;

        case(instruction[6 : 0]) //opcode

            7'b1101111: //JAL
            begin
                the_branch_is_taken = 1'b1;
                address_to_branch = pc + offset_of_JTYPE_instrctions;
                retrun_address_from_JAL = pc + 32'd4;
                retrun_address_usage = 1'b1;
                retrun_address_reg = instruction[11 : 7];
                flush_indicator = 1'b1;
            end

            7'b1100111: //JALR
            begin
                the_branch_is_taken = 1'b1;
                address_to_branch = (pc + offset_of_ITYPE_instrctions);
                address_to_branch[0] = 0;
                retrun_address_from_JAL = pc + 32'd4;
                retrun_address_usage = 1'b1;
                retrun_address_reg = instruction[11 : 7];
                flush_indicator = 1'b1;
            end

            7'b1100011: //BRANCH
            case(instruction[14 : 12]) //FUNC3

                3'b000: //BEQ
                begin
                    the_branch_is_taken = (first_operand == second_operand );
                    if(first_operand == second_operand) begin
                      address_to_branch = pc + 32'(signed'(immediate_value_of_BTYPE_instructions));
                    end
                    else begin
                      address_to_branch = pc + 32'd4;
                    end
                    flush_indicator = the_branch_is_taken;
                end

                3'b001: //BNE
                begin
                    the_branch_is_taken = (first_operand != second_operand );
                    if(first_operand != second_operand) begin
                      address_to_branch = pc + 32'(signed'(immediate_value_of_BTYPE_instructions));
                    end
                    else begin
                      address_to_branch = pc + 32'd4;
                    end
                    flush_indicator = the_branch_is_taken;
                end

                3'b100: //BLT
                begin
                    the_branch_is_taken = (signed'(first_operand) < signed'(second_operand) );
                    if(signed'(first_operand) < signed'(second_operand)) begin
                      address_to_branch = pc + 32'(signed'(immediate_value_of_BTYPE_instructions));
                    end
                    else begin
                      address_to_branch = pc + 32'd4;
                    end
                    flush_indicator = the_branch_is_taken;
                end

                3'b101: //BGE
                begin
                    the_branch_is_taken = (signed'(first_operand) >= signed'(second_operand) );
                    if(signed'(first_operand) >= signed'(second_operand)) begin
                      address_to_branch = pc + 32'(signed'(immediate_value_of_BTYPE_instructions));
                    end
                    else begin
                      address_to_branch = pc + 32'd4;
                    end
                    flush_indicator = the_branch_is_taken;
                end

                3'b110: //BLTU
                begin
                    the_branch_is_taken = (unsigned'(first_operand) < unsigned'(second_operand) );
                    if(unsigned'(first_operand) < unsigned'(second_operand)) begin
                      address_to_branch = pc + 32'(signed'(immediate_value_of_BTYPE_instructions));
                    end
                    else begin
                      address_to_branch = pc + 32'd4;
                    end
                    flush_indicator = the_branch_is_taken;
                end

                3'b111: //BGEU
                begin
                    the_branch_is_taken = (unsigned'(first_operand) >= unsigned'(second_operand) );
                    if(unsigned'(first_operand) >= unsigned'(second_operand)) begin
                      address_to_branch = pc + 32'(signed'(immediate_value_of_BTYPE_instructions));
                    end
                    else begin
                      address_to_branch = pc + 32'd4;
                    end
                    flush_indicator = the_branch_is_taken;
                end
            endcase
        endcase
    end

endmodule
