#!/bin/bash

#Do this for every file which has a number
for FILE in render_tb_out_*.pgm ; do
	for FRAME in ${FILE}_*.pgm ; do 
		BNAME=$(basename ${FRAME} .pgm)
		
		#Convert each frame of the pgm into a gif
		convert $FRAME ${BNAME}.gif
	done

	#May be broken...
	convert -delay 100 -loop 0 ${FILE}_*.gif ${FILE}.gif
done
