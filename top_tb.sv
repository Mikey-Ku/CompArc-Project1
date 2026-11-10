`timescale 10ns/10ns
`include "top.sv"

module top_tb;

    logic clk = 0;
    int errors = 0;

    logic LED0, RGB_R0, RGB_G0, RGB_B0;
    logic LED1, RGB_R1, RGB_G1, RGB_B1;

    top #(
        .PROGRAM    ("programs/rv32i_test")
    ) u0 (
        .clk        (clk),
        .LED        (LED0),
        .RGB_R      (RGB_R0),
        .RGB_G      (RGB_G0),
        .RGB_B      (RGB_B0)
    );

    top #(
        .PROGRAM    ("programs/rv32i_coverage")
    ) u1 (
        .clk        (clk),
        .LED        (LED1),
        .RGB_R      (RGB_R1),
        .RGB_G      (RGB_G1),
        .RGB_B      (RGB_B1)
    );

    task check(input string name, input logic [31:0] actual, input logic [31:0] expected);
        if (actual === expected)
            $display("PASS  %-44s %h", name, actual);
        else begin
            $display("FAIL  %-44s %h (expected %h)", name, actual, expected);
            errors++;
        end
    endtask

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        #40000

        $display("\nprograms/rv32i_test");
        $display("U-type");
        check("lui x1, 0xFEDCC + addi x1, x1, 0xA98", u0.u0.u0.registers[1], 32'hFEDCBA98);
        check("auipc x10, 0x12345 at 0x1028", u0.u0.u0.registers[10], 32'h12346028);
        $display("I-type ALU");
        check("srli x2, x1, 4", u0.u0.u0.registers[2], 32'h0FEDCBA9);
        check("srai x3, x1, 4", u0.u0.u0.registers[3], 32'hFFEDCBA9);
        check("xori x4, x3, -1", u0.u0.u0.registers[4], 32'h00123456);
        check("addi x5, x0, 2", u0.u0.u0.registers[5], 32'h00000002);
        check("ori x9, x8, 7", u0.u0.u0.registers[9], 32'h0048D15F);
        $display("R-type ALU");
        check("add x6, x5, x4", u0.u0.u0.registers[6], 32'h00123458);
        check("sub x7, x6, x4", u0.u0.u0.registers[7], 32'h00000002);
        check("sll x8, x4, x5", u0.u0.u0.registers[8], 32'h0048D158);
        check("slt x11, x3, x4", u0.u0.u0.registers[11], 32'h00000001);
        check("sltu x12, x3, x4", u0.u0.u0.registers[12], 32'h00000000);
        $display("Jumps and branches");
        check("jal x13, 0x28 at 0x1034", u0.u0.u0.registers[13], 32'h00001038);
        check("jalr x14, 0(x13) at 0x105C", u0.u0.u0.registers[14], 32'h00001060);
        check("beq loop counts x15 down to 0", u0.u0.u0.registers[15], 32'h00000000);
        check("jal x16, -8 at 0x1044", u0.u0.u0.registers[16], 32'h00001048);
        check("bltu not taken, blt taken to 0x1060", u0.u0.u0.registers[17], 32'h000000C0);
        $display("Loads and stores (LED peripheral)");
        check("sb x17 to 0xFFFFFFFC..F + lw x18", u0.u0.u0.registers[18], 32'hC0C0C0C0);
        check("lh x20, -4(x0)", u0.u0.u0.registers[20], 32'hFFFFC0C0);
        check("lhu x21, -4(x0)", u0.u0.u0.registers[21], 32'h0000C0C0);
        check("lb x22, -4(x0)", u0.u0.u0.registers[22], 32'hFFFFFFC0);
        check("lbu x23, -4(x0)", u0.u0.u0.registers[23], 32'h000000C0);
        if (u0.u0.u0.registers[19] > 0 && u0.u0.u0.registers[19] < 1000)
            $display("PASS  %-44s %h", "lw x19, -12(x0) reads micros", u0.u0.u0.registers[19]);
        else begin
            $display("FAIL  %-44s %h", "lw x19, -12(x0) reads micros", u0.u0.u0.registers[19]);
            errors++;
        end

        $display("\nprograms/rv32i_coverage");
        $display("I-type ALU");
        check("addi x1, x0, -5", u1.u0.u0.registers[1], 32'hFFFFFFFB);
        check("slti x3, x1, 0", u1.u0.u0.registers[3], 32'h00000001);
        check("sltiu x4, x2, -1", u1.u0.u0.registers[4], 32'h00000001);
        check("andi x5, x1, 0x0F0", u1.u0.u0.registers[5], 32'h000000F0);
        check("slli x6, x2, 30", u1.u0.u0.registers[6], 32'hC0000000);
        $display("R-type ALU");
        check("and x7, x1, x2", u1.u0.u0.registers[7], 32'h00000003);
        check("or x8, x1, x2", u1.u0.u0.registers[8], 32'hFFFFFFFB);
        check("xor x9, x1, x2", u1.u0.u0.registers[9], 32'hFFFFFFF8);
        check("srl x10, x6, x2", u1.u0.u0.registers[10], 32'h18000000);
        check("sra x11, x6, x2", u1.u0.u0.registers[11], 32'hF8000000);
        $display("Branches (each taken once and not taken once)");
        check("x12 sums only the not-taken paths", u1.u0.u0.registers[12], 32'h00000AA9);
        $display("Loads and stores (data memory)");
        check("sw x13, 0(x0) + lw x14, 0(x0)", u1.u0.u0.registers[14], 32'h12345678);
        check("sh x1, 4(x0) + sh x2, 6(x0) + lw x15", u1.u0.u0.registers[15], 32'h0003FFFB);
        check("sb x2, 1(x0) + lw x16, 0(x0)", u1.u0.u0.registers[16], 32'h12340378);
        check("lh x17, 4(x0)", u1.u0.u0.registers[17], 32'hFFFFFFFB);
        check("lhu x18, 4(x0)", u1.u0.u0.registers[18], 32'h0000FFFB);
        check("lb x19, 2(x0)", u1.u0.u0.registers[19], 32'h00000034);
        check("lb x20, 4(x0)", u1.u0.u0.registers[20], 32'hFFFFFFFB);
        check("lbu x21, 4(x0)", u1.u0.u0.registers[21], 32'h000000FB);
        check("sw x1, 8(x0) + sb x2, 11(x0) + lw x22", u1.u0.u0.registers[22], 32'h03FFFFFB);
        $display("Other");
        check("addi x0, x0, 5 leaves x0 at zero", u1.u0.u0.registers[0], 32'h00000000);
        check("add x23, x0, x0 after fence", u1.u0.u0.registers[23], 32'h00000000);
        check("jalr x24, 0(x24) with rd = rs1", u1.u0.u0.registers[24], 32'h000010F0);
        check("jalr clears bit 0 and skips x25", u1.u0.u0.registers[25], 32'h00000000);
        check("addi x26 runs after the jalr", u1.u0.u0.registers[26], 32'h00000002);
        check("program ends in the done loop", u1.u0.pc, 32'h000010F8);

        if (errors == 0)
            $display("\nALL TESTS PASSED");
        else
            $display("\n%0d TESTS FAILED", errors);
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
