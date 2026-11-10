    addi s0, x0, 0
    lw s1, -8(x0)

wait:
    lw t0, -8(x0)
    sub t1, t0, s1
    addi t2, x0, 2
    bltu t1, t2, wait
    addi s1, s1, 2
    addi s0, s0, 1
    addi t2, x0, 1536
    blt s0, t2, color
    addi s0, x0, 0

color:
    andi t3, s0, 255
    xori t4, t3, 255
    srli t5, s0, 8
    addi t6, x0, 255
    beq t5, x0, segment0
    addi t2, x0, 1
    beq t5, t2, segment1
    addi t2, x0, 2
    beq t5, t2, segment2
    addi t2, x0, 3
    beq t5, t2, segment3
    addi t2, x0, 4
    beq t5, t2, segment4
    jal x0, segment5

segment0:
    addi a0, t6, 0
    addi a1, t3, 0
    addi a2, x0, 0
    jal x0, show
segment1:
    addi a0, t4, 0
    addi a1, t6, 0
    addi a2, x0, 0
    jal x0, show
segment2:
    addi a0, x0, 0
    addi a1, t6, 0
    addi a2, t3, 0
    jal x0, show
segment3:
    addi a0, x0, 0
    addi a1, t4, 0
    addi a2, t6, 0
    jal x0, show
segment4:
    addi a0, t3, 0
    addi a1, x0, 0
    addi a2, t6, 0
    jal x0, show
segment5:
    addi a0, t6, 0
    addi a1, x0, 0
    addi a2, t4, 0

show:
    andi a3, s0, 511
    addi t2, x0, 256
    blt a3, t2, pack
    xori a3, a3, 511

pack:
    slli a3, a3, 24
    slli a0, a0, 16
    slli a1, a1, 8
    or a0, a0, a1
    or a0, a0, a2
    or a0, a0, a3
    sw a0, -4(x0)
    jal x0, wait
