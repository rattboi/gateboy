
testbench_src=testbenches/top.sv
peripherals_src=$(wildcard peripherals/*.sv)
processor_src=$(wildcard processor/*.sv)
programs_src=$(wildcard programs/*.sv)
system_src=$(wildcard system/*.sv)

all:
	vlog -O5 +cover $(testbench_src) $(system_src) $(processor_src) $(peripherals_src) $(programs_src)
	vsim -c -do questa.tcl -coverage -voptargs="+cover=bcfst" testbench
report: 
	vsim -c -do report.tcl
once:
	vlib work

