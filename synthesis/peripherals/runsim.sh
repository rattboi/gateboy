#!/bin/sh
export PATH=/pkgs/mentor/questa/current/questasim/bin:$PATH
MODULE=tb
FILES='video_tb.sv video_types.sv'
for i in "$FILES" 
do
    vlog -sv $i 2>&1 || exit
done
vsim -c $MODULE -voptargs="+acc" -do "log -r /*; run -all"  1>&2 || exit 
