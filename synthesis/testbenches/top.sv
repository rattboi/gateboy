// `default_nettype none
`timescale 1ns / 1ps

// Main board module.
module testbench(
);
  bit coreclk, cpu_clock;
  bit [2:0] clock_divider;
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

  assign Di = A[15] ? Di_wram : cart_rom[A];

  initial 
    forever #100 coreclk = ~coreclk;
   
<<<<<<< HEAD
=======
   initial begin 
    clock_divider = '0;
    coreclk = 0;
    cpu_clock = 0;
    reset_init = 1;
    reset = 1;
    #3000
    reset_init = 0;
    reset = 0;
   end
 
 
  always @(posedge coreclk)
  if (PC == 16'h206)
    $display("BALLS");
  
>>>>>>> 52e31cea1c16587dc249a998036b774ea932e9cb
  always @(posedge coreclk)
  begin
    clock_divider <= clock_divider + 1;
    cpu_clock <= clock_divider[2];
  end

<<<<<<< HEAD
  top_program tp(cpu_clock, reset, cart_rom);
=======
  always
    #10000 if (PC > 255)
      if (DE > 16'hC000)
      begin
        $display("PC = %h  DE = %h  HL = %h  BC = %h", PC, DE, HL, BC);
      end

  integer file; 
  int dontcare;
  
  initial 
  begin
    file = $fopen("../tests/01-special.gb","rb");  
    if (!file)
      $fatal("**** couldn't load cart rom into memory");
    
    else
    begin
      $display("**** loaded cart rom into memory");
      dontcare = $fread(cart_rom[0], file, 0, 32767);
      $fclose(file);
    end
  end
>>>>>>> 52e31cea1c16587dc249a998036b774ea932e9cb

  // create the germberh
  gameboy gameboy ( .*,
                    .clock(coreclk),
                    .cpu_clock(cpu_clock)
                  );
 
  // WRAM
  async_mem #(.asz(13), .depth(8192)) wram (
    .rd_data(Di_wram),
    .wr_clk(coreclk),
    .wr_data(Do),
    .wr_cs(!cs_n && !wr_n),
    .addr(A[12:0]),
    .rd_cs(!cs_n && !rd_n)
  );
  
  // VRAM
  async_mem #(.asz(13), .depth(8192)) vram (
    .rd_data(Di_vram),
    .wr_clk(coreclk),
    .wr_data(Do_vram),
    .wr_cs(!cs_vram_n && !wr_vram_n),
    .addr(A_vram[12:0]),
    .rd_cs(!cs_vram_n && !rd_vram_n)
  );
 endmodule
