// `default_nettype none
// `timescale 1ns / 1ps

// Main board module.
module testbench(
);
  bit coreclk, cpu_clock;
  bit reset, reset_init;
  
  // GB <-> Cartridge + WRAM
  wire [15:0] A;
  wire [7:0] Di;
  wire [7:0] Do;
  wire wr_n, rd_n, cs_n;
  
  // GB <-> VRAM
  wire [15:0] A_vram;
  wire [7:0] Di_vram;
  wire [7:0] Do_vram;
  wire wr_vram_n, rd_vram_n, cs_vram_n;
  
  // Internal ROMs and RAMs
  reg [7:0] cart_rom [0:32767];
  wire [7:0] Di_wram;
  
  assign Di = A[14] ? Di_wram : cart_rom[A];

  initial begin 
    coreclk = 0;
    forever #100 coreclk = ~coreclk;
   end
  
  initial
    $readmemh("data/tetris.rom", cart_rom, 0, 32767);

  // create the germberh
  gameboy gameboy (.*);
  
  // WRAM
  async_mem #(.asz(8), .depth(8192)) wram (
    .rd_data(Di_wram),
    .wr_clk(clock),
    .wr_data(Do),
    .wr_cs(!cs_n && !wr_n),
    .addr(A),
    .rd_cs(!cs_n && !rd_n)
  );
  
  // VRAM
  async_mem #(.asz(8), .depth(8192)) vram (
    .rd_data(Di_vram),
    .wr_clk(clock),
    .wr_data(Do_vram),
    .wr_cs(!cs_vram_n && !wr_vram_n),
    .addr(A_vram),
    .rd_cs(!cs_vram_n && !rd_vram_n)
  );
 endmodule