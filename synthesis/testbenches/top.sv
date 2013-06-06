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

  // Video Display
  wire  [1:0] pixel_data;
  wire        pixel_clock;
  wire        pixel_latch;
  wire        hsync;
  wire        vsync;
  
  // GB <-> VRAM
  wire [15:0] A_vram;
  wire [7:0] Di_vram;
  wire [7:0] Do_vram;
  wire wr_vram_n, rd_vram_n, cs_vram_n;
  
  // Internal ROMs and RAMs
  reg [7:0] cart_rom [0:32767];
  wire [7:0] Di_wram;
  
  // CPU Debug Pins
  wire  [7:0] dbg_led;
  wire [15:0] PC;
  wire [15:0] SP;
  wire [15:0] AF;
  wire [15:0] BC;
  wire [15:0] DE;
  wire [15:0] HL;
  wire [15:0] A_cpu;
  wire  [7:0] Di_cpu;
  wire  [7:0] Do_cpu;
  
  // Audio
  wire        audio_left;
  wire        audio_right;

  // Controller
  wire  [3:0] joypad_data;
  wire  [1:0] joypad_sel;

  assign Di = A[14] ? Di_wram : cart_rom[A];

  initial begin 
    coreclk = 0;
    reset_init = 0;
    reset = 0;
    #100 
    coreclk = 1;
    reset_init = 1;
    reset = 1;
    forever #100 coreclk = ~coreclk;
   end
  
  initial
    $readmemh("data/tetris.rom", cart_rom, 0, 32767);

  // create the germberh
  gameboy gameboy ( .*,
                    .clock(coreclk),
                    .cpu_clock(coreclk)
                    );
                    
  // gameboy gameboy (
  //   .clock(clock),
  //   .cpu_clock(cpu_clock),
  //   .reset(reset),
  //   .reset_init(reset_init),
  //   .A(A),
  //   .Di(Di),
  //   .Do(Do),
  //   .wr_n(wr_n),
  //   .rd_n(rd_n),
  //   .cs_n(cs_n),
  //   .A_vram(A_vram),
  //   .Di_vram(Di_vram),
  //   .Do_vram(Do_vram),
  //   .wr_vram_n(wr_vram_n),
  //   .rd_vram_n(rd_vram_n),
  //   .cs_vram_n(cs_vram_n),
  //   .pixel_data(pixel_data),
  //   .pixel_clock(pixel_clock),
  //   .pixel_latch(pixel_latch),
  //   .hsync(hsync),
  //   .vsync(vsync),
  //   .joypad_data(joypad_data),
  //   .joypad_sel(joypad_sel),
  //   .audio_left(audio_left),
  //   .audio_right(audio_right),
  //   // debug output
  //   .dbg_led(LED),
  //   .PC(PC),
  //   .SP(SP),
  //   .AF(AF),
  //   .BC(BC),
  //   .DE(DE),
  //   .HL(HL),
  //   .A_cpu(A_cpu),
  //   .Di_cpu(Di_cpu),
  //   .Do_cpu(Do_cpu)
  // );                    
  
  // WRAM
  async_mem #(.asz(16), .depth(8192)) wram (
    .rd_data(Di_wram),
    .wr_clk(coreclk),
    .wr_data(Do),
    .wr_cs(!cs_n && !wr_n),
    .addr(A),
    .rd_cs(!cs_n && !rd_n)
  );
  
  // VRAM
  async_mem #(.asz(16), .depth(8192)) vram (
    .rd_data(Di_vram),
    .wr_clk(coreclk),
    .wr_data(Do_vram),
    .wr_cs(!cs_vram_n && !wr_vram_n),
    .addr(A_vram),
    .rd_cs(!cs_vram_n && !rd_vram_n)
  );
 endmodule