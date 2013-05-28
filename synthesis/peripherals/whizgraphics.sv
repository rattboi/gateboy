module whizgraphics(interface db);
   import video_types::*;
   bit [db.DATA_SIZE-1:0] bus_reg;
   bit                    enable;
   assign db.data = enable ? bus_reg : 'z;

    localparam LCDC_ADDR = 16'hff40;
    localparam STAT_ADDR = 16'hff41;
    localparam LCD_POS_BASE_ADDR = 16'hff42;
    localparam LCD_PALLET_BASE_ADDR = 16'hff47;
    localparam VRAM_PALLET_ADDR = 16'h8000;
    localparam VRAM_PALLET_MASK = 16'h1fff;
    localparam VRAM_BACKGROUND1_ADDR = 16'h9800;
    localparam VRAM_BACKGROUND1_MASK = 16'h03ff;
    localparam VRAM_BACKGROUND2_ADDR = 16'h9c00;
    localparam VRAM_BACKGROUND2_MASK = 16'h0fff;


   parameter OAM_LOC = 16'hfe00;
   parameter OAM_MASK = 16'h00ff;
   SpriteAttributesTable oam_table;

   // 
   always_ff @(posedge db.clk) begin
      if (db.writing() && db.selected(OAM_LOC, OAM_MASK)) begin
         oam_table.Bits[db.addr & OAM_MASK] = db.data;
      end
      else if (db.reading() && db.selected(OAM_LOC, OAM_MASK)) begin
         enable = 1;
         bus_reg = oam_table.Bits[db.addr & OAM_MASK];
//         $display("reading %x from %x", oam_table.Bits[db.addr & OAM_MASK], db.addr);
      end
      else
        enable = 0;
   end
endmodule
