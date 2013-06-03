#!/bin/sh
export PATH=/pkgs/mentor/questa/current/questasim/bin:$PATH
MODULES="pgm_tb tb_render w_tb w_mem_tb"

# if the user supplied testbenches to run, run them instead
echo "$@"

if [ $# -gt 0 ] ; then

MODULES="$@"
fi
echo Testing modules "$MODULES"
# convert spaces to newlines to allow for multiple tbs to be run
MODULES=`echo "$MODULES" | tr " " "\n"`
FILES='video_types.sv whizgraphics_render_tb.sv whizzgraphics_mem_tb.sv whizzgraphics_tb.sv  whizgraphics.sv pgm_tb.sv data_bus.inf data_bus_tb.sv memory.sv'
for i in "$FILES" 
do
    vlog  -sv $i 2>&1 || exit
done
# run all of the testbenches specified
for i in $MODULES ; do
    echo Testing $i
    vsim -c $i -voptargs="+acc" -do "log -r /*; run -all; exit"  1>&2 || exit
done
