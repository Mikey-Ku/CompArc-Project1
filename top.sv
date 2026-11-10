`include "memory.sv"
`include "cpu.sv"

module top #(
    parameter PROGRAM = "programs/blink"
)(
    input logic clk,
    output logic LED,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    logic [2:0] funct3;
    logic dmem_wren;
    logic [31:0] dmem_address;
    logic [31:0] dmem_data_in;
    logic [31:0] dmem_data_out;
    logic [31:0] imem_address;
    logic [31:0] imem_data_out;

    logic reset;
    logic led;
    logic red;
    logic green;
    logic blue;

    cpu u0 (
        .clk            (clk),
        .imem_data_out  (imem_data_out),
        .dmem_data_out  (dmem_data_out),
        .imem_address   (imem_address),
        .dmem_address   (dmem_address),
        .dmem_data_in   (dmem_data_in),
        .dmem_wren      (dmem_wren),
        .funct3         (funct3)
    );

    memory #(
        .IMEM_INIT_FILE_PREFIX  (PROGRAM)
    ) u1 (
        .clk            (clk),
        .funct3         (funct3),
        .dmem_wren      (dmem_wren),
        .dmem_address   (dmem_address),
        .dmem_data_in   (dmem_data_in),
        .imem_address   (imem_address),
        .imem_data_out  (imem_data_out),
        .dmem_data_out  (dmem_data_out),
        .reset          (reset),
        .led            (led),
        .red            (red),
        .green          (green),
        .blue           (blue)
    );

    assign LED = ~led;
    assign RGB_R = ~red;
    assign RGB_G = ~green;
    assign RGB_B = ~blue;

endmodule
