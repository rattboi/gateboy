onerror {resume}
quietly virtual signal -install /testbench { /testbench/AF[15:8]} regA
quietly virtual signal -install /testbench { /testbench/AF[7:0]} regF
quietly virtual signal -install /testbench { /testbench/BC[15:8]} regB
quietly virtual signal -install /testbench { /testbench/BC[7:0]} regC
quietly virtual signal -install /testbench { /testbench/DE[15:8]} regD
quietly virtual signal -install /testbench { /testbench/DE[7:0]} regE
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group testbench -radix binary /testbench/A
add wave -noupdate -expand -group testbench /testbench/Di
add wave -noupdate -expand -group testbench /testbench/Do
add wave -noupdate -expand -group testbench /testbench/wr_n
add wave -noupdate -expand -group testbench /testbench/rd_n
add wave -noupdate -expand -group testbench /testbench/cs_n
add wave -noupdate -expand -group testbench /testbench/A_vram
add wave -noupdate -expand -group testbench /testbench/Di_vram
add wave -noupdate -expand -group testbench /testbench/Do_vram
add wave -noupdate -expand -group testbench /testbench/wr_vram_n
add wave -noupdate -expand -group testbench /testbench/rd_vram_n
add wave -noupdate -expand -group testbench /testbench/cs_vram_n
add wave -noupdate -expand -group testbench /testbench/Di_wram
add wave -noupdate -expand -group testbench /testbench/PC
add wave -noupdate -expand -group testbench /testbench/SP
add wave -noupdate -expand -group testbench /testbench/regA
add wave -noupdate -expand -group testbench /testbench/regF
add wave -noupdate -expand -group testbench /testbench/regB
add wave -noupdate -expand -group testbench /testbench/regC
add wave -noupdate -expand -group testbench /testbench/regD
add wave -noupdate -expand -group testbench /testbench/regE
add wave -noupdate -expand -group testbench /testbench/HL
add wave -noupdate -expand -group testbench /testbench/A_cpu
add wave -noupdate -expand -group testbench /testbench/Di_cpu
add wave -noupdate -expand -group testbench /testbench/Do_cpu
add wave -noupdate -group combined_regs /testbench/AF
add wave -noupdate -group combined_regs /testbench/BC
add wave -noupdate -group combined_regs /testbench/DE
add wave -noupdate -group wram /testbench/wram/addr
add wave -noupdate -group wram /testbench/wram/mem
add wave -noupdate -group wram /testbench/wram/rd_cs
add wave -noupdate -group wram /testbench/wram/rd_data
add wave -noupdate -group wram /testbench/wram/wr_clk
add wave -noupdate -group wram /testbench/wram/wr_cs
add wave -noupdate -group wram /testbench/wram/wr_data
add wave -noupdate -group memory /testbench/gameboy/memory/cs_boot_rom
add wave -noupdate -group memory /testbench/gameboy/memory/cs_high_ram
add wave -noupdate -group memory /testbench/gameboy/memory/cs_interrupt
add wave -noupdate -group memory /testbench/gameboy/memory/cs_joypad
add wave -noupdate -group memory /testbench/gameboy/memory/cs_jump_rom
add wave -noupdate -group memory /testbench/gameboy/memory/cs_n
add wave -noupdate -group memory /testbench/gameboy/memory/cs_ppu
add wave -noupdate -group memory /testbench/gameboy/memory/cs_sound
add wave -noupdate -group memory /testbench/gameboy/memory/cs_timer
add wave -noupdate -group memory /testbench/gameboy/memory/A
add wave -noupdate -group memory /testbench/gameboy/memory/A_cpu
add wave -noupdate -group memory /testbench/gameboy/memory/A_high_ram
add wave -noupdate -group memory /testbench/gameboy/memory/A_jump_rom
add wave -noupdate -group memory /testbench/gameboy/memory/A_ppu
add wave -noupdate -group memory /testbench/gameboy/memory/Di
add wave -noupdate -group memory /testbench/gameboy/memory/Di_cpu
add wave -noupdate -group memory /testbench/gameboy/memory/Di_ppu
add wave -noupdate -group memory /testbench/gameboy/memory/Do
add wave -noupdate -group memory /testbench/gameboy/memory/Do_cpu
add wave -noupdate -group memory /testbench/gameboy/memory/Do_high_ram
add wave -noupdate -group memory /testbench/gameboy/memory/Do_interrupt
add wave -noupdate -group memory /testbench/gameboy/memory/Do_joypad
add wave -noupdate -group memory /testbench/gameboy/memory/Do_ppu
add wave -noupdate -group memory /testbench/gameboy/memory/Do_sound
add wave -noupdate -group memory /testbench/gameboy/memory/Do_timer
add wave -noupdate -group memory /testbench/gameboy/memory/boot_rom_enable
add wave -noupdate -group memory /testbench/gameboy/memory/rd_cpu_n
add wave -noupdate -group memory /testbench/gameboy/memory/rd_n
add wave -noupdate -group memory /testbench/gameboy/memory/rd_ppu_n
add wave -noupdate -group memory /testbench/gameboy/memory/reset
add wave -noupdate -group memory /testbench/gameboy/memory/wr_cpu_n
add wave -noupdate -group memory /testbench/gameboy/memory/wr_n
add wave -noupdate -group memory /testbench/gameboy/memory/wr_ppu_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {684744556859 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 386
configure wave -valuecolwidth 188
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {684738399269 ps} {684744613351 ps}
bookmark add wave bookmark0 {{684738399269 ps} {684770684249 ps}} 0
