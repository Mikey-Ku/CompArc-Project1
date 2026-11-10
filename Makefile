tools ?= $(HOME)/Tools/oss-cad-suite/bin/
riscv ?= $(HOME)/Tools/xpack-riscv-none-elf-gcc-14.2.0-3/bin/riscv-none-elf-
filename = top
pcf_file = iceBlinkPico.pcf
p = blink

build:
	$(tools)yosys -p "synth_ice40 -top top -json $(filename).json" $(filename).sv
	$(tools)nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	$(tools)icepack $(filename).asc $(filename).bin

prog: #for sram
	$(tools)dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

asm:
	$(riscv)as -march=rv32i -o programs/$(p).o programs/$(p).s
	$(riscv)ld -Ttext=0x1000 -e 0x1000 -o programs/$(p).elf programs/$(p).o
	$(riscv)objcopy -O binary programs/$(p).elf programs/$(p).img
	hexdump -v -e '1/4 "%08x\n"' programs/$(p).img | awk '{ print } END { for (i = NR; i < 1024; i++) print "00000000" }' > programs/$(p).txt
	python3 split_memhfile.py programs/$(p).txt
	$(riscv)objdump -d -M no-aliases,numeric programs/$(p).elf
	rm programs/$(p).o programs/$(p).elf programs/$(p).img

test:
	$(tools)iverilog -g2012 -o top_tb.vvp top_tb.sv
	$(tools)vvp top_tb.vvp

sim: test
	$(tools)gtkwave top_tb.vcd

clean:
	rm -rf $(filename).asc $(filename).json $(filename).bin *.vvp *.vcd
