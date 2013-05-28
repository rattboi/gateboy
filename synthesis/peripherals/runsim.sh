#!/bin/sh
export PATH=/pkgs/mentor/questa/current/questasim/bin:$PATH
MODULE=pgm_tb
FILES='whizzgraphics_tb.sv video_types.sv whizgraphics.sv ../interconnect/data_bus.inf pgm_tb.sv'
for i in "$FILES" 
do
    vlog +incdir+../interconnect -sv $i 2>&1 || exit
done
vsim +incdir+../interconnect -c $MODULE -voptargs="+acc" -do "log -r /*; run -all"  1>&2 || exit 
