module whizgraphics(interface db);
   import video_types::*;
   bit [db.DATA_SIZE-1:0] bus_reg;
   bit                    enable;
   assign db.data = enable ? bus_reg : 'z;

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
