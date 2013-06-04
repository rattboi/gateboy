// This file contains tests to verify that the memory locations in the
// DMG graphics driver can be accessed properly

module w_mem_tb();
   import video_types::*;
   bit clk = 0;
   DataBus db(clk);
   wire renderComplete;
   Lcd lcd;
   whizgraphics #(.DEBUG_OUT(0)) DUT(.*, .db(db.peripheral), .drawline(clk));
   bit [db.DATA_SIZE-1:0] r;
   bit [db.ADDR_SIZE-1:0] address;
   int        numPassed = 0;
   bit [db.DATA_SIZE-1:0] d;
   
   initial forever #10 clk = ~clk;

   task tickleBus(int baseaddr, int size, int mask, int maxtests = 9000);
      
      bit [db.ADDR_SIZE-1:0] address;
      for (int i = 0; i < maxtests; i++) begin : write 
         if (i >= size) disable write;
         r = $urandom;
         address = (i & mask) + baseaddr;
         db.write(r, address);
         db.read(address,d);
         if (d != r)
           $display("Could not transfer byte %x to addr %x", r, address);
         else begin
            numPassed++;
         end
      end 
      
   endtask
   
   initial begin
   // Test the OAM
      tickleBus(DUT.OAM_LOC, DUT.OAM_SIZE, DUT.OAM_MASK);
      tickleBus(DUT.VRAM_BACKGROUND1_ADDR, DUT.VRAM_BACKGROUND1_SIZE, DUT.VRAM_BACKGROUND1_MASK);
      tickleBus(DUT.VRAM_TILES_ADDR, DUT.VRAM_TILES_SIZE, DUT.VRAM_TILES_MASK);

      
      $display("Passed %d tests", numPassed);
      $display("Attempting to draw pretty picture...");
      if (renderComplete) begin
         $display("yay! art.");
      end else begin
         $display("aww... didn't work, still wrote out shite");
      end
              writeLCD(lcd, "out.pgm");
      $finish;
   end
endmodule
