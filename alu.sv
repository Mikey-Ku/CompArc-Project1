module alu (
    input logic     [31:0] a,
    input logic     [31:0] b,
    input logic     [2:0] funct3,
    input logic     alt,
    output logic    [31:0] result
);

    always_comb begin
        case (funct3)
            3'b000: result = alt ? a - b : a + b;
            3'b001: result = a << b[4:0];
            3'b010: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            3'b011: result = (a < b) ? 32'd1 : 32'd0;
            3'b100: result = a ^ b;
            3'b101: begin
                if (alt)
                    result = $signed(a) >>> b[4:0];
                else
                    result = a >> b[4:0];
            end
            3'b110: result = a | b;
            3'b111: result = a & b;
        endcase
    end

endmodule
