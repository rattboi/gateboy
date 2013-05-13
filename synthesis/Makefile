# Project: Gateboy
# Author: Tyler Tricker
# 
# this makefile is for: 
#      - synthesizing the project code
#      - running testbenches
#      - cleaning the file tree before a checkin

project=gateboy
top_level_file=system\top.sv
family="Cyclone II"
packing_option=minimize_area
part=EP2C20F484C7 

outdir=output_files
interconnect_src=$(wildcard interconnect\*.sv)
peripherals_src=$(wildcard peripherals\*.sv)
processor_src=$(wildcard processor\*.sv)
system_src=$(wildcard system\*.sv)


#build code
all: 
	echo "TODO - ALL"

#This area could use some work - maybe cmake would be better for this

.PHONY: synth
synth: $(outdir)\$(project).done

# Run mapper
$(outdir)\$(project).map.rpt: $(interconnect_src) $(peripherals_src) $(processor_src $system_src)
	quartus_map $(project) --source="$(top_level_file)" --family=$(family)

# Run fitter
$(outdir)\$(project).flow.rpt: $(outdir)\$(project).map.rpt
	quartus_fit $(project) --part=$(part) --pack_register=$(packing_option)

# Run assembler
$(outdir)\$(project).done: $(outdir)\$(project).flow.rpt
	quartus_asm $(project)
	quartus_sta $(project)

#simulate all of the testbenches
test: synth
	echo "TODO"

#clean the filetree
.PHONY: clean
clean:
	rm -rf simulation
	rm -rf output_files
	rm -rf incremental_db
	rm -rf db
	rm -rf *.dpf


# add the quartus tools to the execution path
.PHONY: qtools
qtools:
	source  .toolspath


