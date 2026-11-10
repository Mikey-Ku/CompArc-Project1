    addi x1, x0, -5             # x1 = 0xFFFFFFFB
    addi x2, x0, 3              # x2 = 0x00000003
    slti x3, x1, 0              # x3 = 0x00000001
    sltiu x4, x2, -1            # x4 = 0x00000001
    andi x5, x1, 0x0F0          # x5 = 0x000000F0
    slli x6, x2, 30             # x6 = 0xC0000000
    and x7, x1, x2              # x7 = 0x00000003
    or x8, x1, x2               # x8 = 0xFFFFFFFB
    xor x9, x1, x2              # x9 = 0xFFFFFFF8
    srl x10, x6, x2             # x10 = 0x18000000
    sra x11, x6, x2             # x11 = 0xF8000000

    addi x12, x0, 0
    beq x2, x2, 1f
    addi x12, x12, 1
1:  beq x1, x2, 2f
    addi x12, x12, 2
2:  bne x1, x2, 3f
    addi x12, x12, 4
3:  bne x2, x2, 4f
    addi x12, x12, 8
4:  blt x1, x2, 5f
    addi x12, x12, 16
5:  blt x2, x1, 6f
    addi x12, x12, 32
6:  bge x2, x1, 7f
    addi x12, x12, 64
7:  bge x1, x2, 8f
    addi x12, x12, 128
8:  bltu x2, x1, 9f
    addi x12, x12, 256
9:  bltu x1, x2, 10f
    addi x12, x12, 512
10: bgeu x1, x2, 11f
    addi x12, x12, 1024
11: bgeu x2, x1, 12f
    addi x12, x12, 2047
12: addi x12, x12, 0            # x12 = 0x00000AA9

    lui x13, 0x12345            # x13 = 0x12345000
    addi x13, x13, 0x678        # x13 = 0x12345678
    sw x13, 0(x0)
    lw x14, 0(x0)               # x14 = 0x12345678
    sh x1, 4(x0)
    sh x2, 6(x0)
    lw x15, 4(x0)               # x15 = 0x0003FFFB
    sb x2, 1(x0)
    lw x16, 0(x0)               # x16 = 0x12340378
    lh x17, 4(x0)               # x17 = 0xFFFFFFFB
    lhu x18, 4(x0)              # x18 = 0x0000FFFB
    lb x19, 2(x0)               # x19 = 0x00000034
    lb x20, 4(x0)               # x20 = 0xFFFFFFFB
    lbu x21, 4(x0)              # x21 = 0x000000FB
    sw x1, 8(x0)
    sb x2, 11(x0)
    lw x22, 8(x0)               # x22 = 0x03FFFFFB

    fence
    addi x0, x0, 5              # x0 stays 0
    add x23, x0, x0             # x23 = 0x00000000
    auipc x24, 0                # x24 = address of this auipc
    addi x24, x24, 17
    jalr x24, 0(x24)            # jumps to auipc + 16, x24 = auipc + 12
    addi x25, x0, 1             # skipped, x25 stays 0
    addi x26, x0, 2             # x26 = 0x00000002

done:
    jal x0, done
