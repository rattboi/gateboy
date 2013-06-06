#!/bin/bash

if [ -z $1 ] 
then
	echo "please enter file name argument"
	exit
fi

BNAME="render_tb_out_$1"

INPUT=`ls | grep "${BNAME}.*.pgm"`
OUTPUT="${BNAME}_ani.gif"

rm -f ${BNAME}_ani.gif
convert -delay 10 -loop 0 $INPUT $OUTPUT

chmod go+r $OUTPUT

