module register_file (
    input logic     clk,
    input logic     write_enable,
    input logic     [4:0] rs1,
    input logic     [4:0] rs2,
    input logic     [4:0] rd,
    input logic     [31:0] rd_value,
    output logic    [31:0] rs1_value,
    output logic    [31:0] rs2_value
);

    logic [31:0] registers [0:31];

    initial begin
        for (int i = 0; i < 32; i++) begin
            registers[i] = 32'd0;
        end
    end

    always_ff @(negedge clk) begin
        if (write_enable && (rd != 5'd0)) begin
            registers[rd] <= rd_value;
        end
        rs1_value <= registers[rs1];
        rs2_value <= registers[rs2];
    end

endmodule
