#!/bin/sh
export PATH=/pkgs/mentor/questa/current/questasim/bin:$PATH
MODULE=pgm_tb

if [ -n "$1" ] ; then
    MODULE=$1
fi
echo Testing module $MODULE
FILES='whizzgraphics_tb.sv video_types.sv whizgraphics.sv pgm_tb.sv data_bus.inf data_bus_tb.sv memory.sv'
for i in "$FILES" 
do
    vlog  -sv $i 2>&1 || exit
done
vsim -c $MODULE -voptargs="+acc" -do "log -r /*; run -all"  1>&2 || exit 
