module immediate (
    input logic     [31:0] instruction,
    output logic    [31:0] immediate
);

    localparam [6:0] LUI    = 7'b0110111;
    localparam [6:0] AUIPC  = 7'b0010111;
    localparam [6:0] JAL    = 7'b1101111;
    localparam [6:0] BRANCH = 7'b1100011;
    localparam [6:0] STORE  = 7'b0100011;

    always_comb begin
        case (instruction[6:0])
            LUI:        immediate = { instruction[31:12], 12'd0 };
            AUIPC:      immediate = { instruction[31:12], 12'd0 };
            JAL:        immediate = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0 };
            BRANCH:     immediate = { {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0 };
            STORE:      immediate = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
            default:    immediate = { {20{instruction[31]}}, instruction[31:20] };
        endcase
    end

endmodule
