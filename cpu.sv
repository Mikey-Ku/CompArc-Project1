`include "register_file.sv"
`include "immediate.sv"
`include "alu.sv"
`include "branch.sv"

module cpu (
    input logic     clk,
    input logic     [31:0] imem_data_out,
    input logic     [31:0] dmem_data_out,
    output logic    [31:0] imem_address,
    output logic    [31:0] dmem_address,
    output logic    [31:0] dmem_data_in,
    output logic    dmem_wren,
    output logic    [2:0] funct3
);

    localparam [2:0] FETCH      = 3'd0;
    localparam [2:0] DECODE     = 3'd1;
    localparam [2:0] EXECUTE    = 3'd2;
    localparam [2:0] MEMORY     = 3'd3;
    localparam [2:0] WRITEBACK  = 3'd4;

    localparam [6:0] LUI        = 7'b0110111;
    localparam [6:0] AUIPC      = 7'b0010111;
    localparam [6:0] JAL        = 7'b1101111;
    localparam [6:0] JALR       = 7'b1100111;
    localparam [6:0] BRANCH     = 7'b1100011;
    localparam [6:0] LOAD       = 7'b0000011;
    localparam [6:0] STORE      = 7'b0100011;
    localparam [6:0] OP_IMM     = 7'b0010011;
    localparam [6:0] OP         = 7'b0110011;

    logic [2:0] state = FETCH;
    logic [31:0] pc = 32'h00001000;
    logic [31:0] instruction = 32'd0;
    logic [31:0] alu_result = 32'd0;
    logic [31:0] load_data = 32'd0;

    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [31:0] rs1_value, rs2_value, immediate;
    logic [31:0] alu_a, alu_b, alu_out;
    logic [2:0] alu_funct3;
    logic alu_alt, taken, rd_write;
    logic [31:0] pc_plus_4, next_pc, rd_value;

    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];

    register_file u0 (
        .clk            (clk),
        .write_enable   (rd_write),
        .rs1            (rs1),
        .rs2            (rs2),
        .rd             (rd),
        .rd_value       (rd_value),
        .rs1_value      (rs1_value),
        .rs2_value      (rs2_value)
    );

    immediate u1 (
        .instruction    (instruction),
        .immediate      (immediate)
    );

    alu u2 (
        .a              (alu_a),
        .b              (alu_b),
        .funct3         (alu_funct3),
        .alt            (alu_alt),
        .result         (alu_out)
    );

    branch u3 (
        .a              (rs1_value),
        .b              (rs2_value),
        .funct3         (funct3),
        .taken          (taken)
    );

    assign alu_a = ((opcode == AUIPC) || (opcode == JAL) || (opcode == BRANCH)) ? pc : rs1_value;
    assign alu_b = (opcode == OP) ? rs2_value : immediate;
    assign alu_funct3 = ((opcode == OP) || (opcode == OP_IMM)) ? funct3 : 3'b000;
    assign alu_alt = ((opcode == OP) || ((opcode == OP_IMM) && (funct3 == 3'b101))) ? instruction[30] : 1'b0;

    assign pc_plus_4 = pc + 32'd4;

    always_comb begin
        case (opcode)
            JAL:        next_pc = alu_result;
            JALR:       next_pc = { alu_result[31:1], 1'b0 };
            BRANCH:     next_pc = taken ? alu_result : pc_plus_4;
            default:    next_pc = pc_plus_4;
        endcase
    end

    always_comb begin
        case (opcode)
            LUI:        rd_value = immediate;
            JAL:        rd_value = pc_plus_4;
            JALR:       rd_value = pc_plus_4;
            LOAD:       rd_value = load_data;
            default:    rd_value = alu_result;
        endcase
    end

    assign rd_write = (state == WRITEBACK) && (opcode != STORE) && (opcode != BRANCH);

    assign imem_address = pc;
    assign dmem_address = alu_result;
    assign dmem_data_in = rs2_value;
    assign dmem_wren = (state == MEMORY) && (opcode == STORE);

    always_ff @(negedge clk) begin
        case (state)
            FETCH: begin
                instruction <= imem_data_out;
                state <= DECODE;
            end
            DECODE: begin
                state <= EXECUTE;
            end
            EXECUTE: begin
                alu_result <= alu_out;
                if ((opcode == LOAD) || (opcode == STORE))
                    state <= MEMORY;
                else
                    state <= WRITEBACK;
            end
            MEMORY: begin
                load_data <= dmem_data_out;
                state <= WRITEBACK;
            end
            WRITEBACK: begin
                pc <= next_pc;
                state <= FETCH;
            end
        endcase
    end

endmodule
