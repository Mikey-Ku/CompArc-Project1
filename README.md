# Project 1

A multicycle, unpipelined RV32I processor in SystemVerilog for the iceBlinkPico. It
implements every base RV32I instruction except `ecall`, `ebreak`, and the CSR instructions,
using the professor's `memory.sv` for 4 kB of data memory, 4 kB of instruction memory, and
the memory-mapped LED and timer peripherals.

`programs/blink.s` runs on the board, cycling the RGB LED through a rainbow while the user
LED breathes. `make test` runs `programs/rv32i_test` and `programs/rv32i_coverage` and
checks every instruction class.

## Files

- `cpu.sv`: five-state FSM (fetch, decode, execute, memory, writeback) and datapath
- `register_file.sv`, `immediate.sv`, `alu.sv`, `branch.sv`: CPU submodules
- `memory.sv`, `split_memhfile.py`: provided memory module and hex splitter
- `top.sv`, `iceBlinkPico.pcf`: board top level and pin map
- `top_tb.sv`: testbench with checks for each instruction class
- `programs/`: assembly sources and their memory files

## Commands

```
make test
make asm p=blink
make build
make prog
```
