#!/bin/bash

wla -o "01-special.s" test.o
wlalink linkfile 01-special.gb

wla -o "02-interrupts.s" test.o
wlalink linkfile "02-interrupts.gb"

wla -o "03-op sp,hl.s" test.o
wlalink linkfile "03-op sp,hl.gb"

wla -o "04-op r,imm.s" test.o
wlalink linkfile "04-op r, imm.gb"

wla -o "05-op rp.s" test.o
wlalink linkfile "05-op rp.gb"

wla -o "06-ld r,r.s" test.o
wlalink linkfile "06-ld r,r.gb"

wla -o "07-jr,jp,call,ret,rst.s" test.o
wlalink linkfile "07-jr,jp,call,ret,rst.gb"

wla -o "08-misc instrs.s" test.o
wlalink linkfile "08-misc instrs.gb"

wla -o "09-op r,r.s" test.o
wlalink linkfile "09-op r,r.gb"

wla -o "10-bit ops.s" test.o
wlalink linkfile "10-bit ops.gb"

wla -o "11-op a,(hl).s" test.o
wlalink linkfile "11-op a,(hl).gb"

